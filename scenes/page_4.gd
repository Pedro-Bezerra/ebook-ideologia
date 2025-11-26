extends Control

# --- Variáveis Originais (Áudio) ---
@onready var button_audio_on = $ButtonAudioON
@onready var button_audio_off = $ButtonAudioOFF

# --- Novas Variáveis para Interação ---
@onready var button_igreja = $Igreja
@onready var button_tv = $TV
@onready var button_industria = $Industria
@onready var characters = [$Indigena1, $Indigena2, $Indigena3]

var touch_id_to_button: Dictionary = {}

var button_to_thought_map = {}
var active_thought_names = []
var current_thought_index = 0

var thought_cycle_timer: Timer
var thought_animation_tween: Tween

const THOUGHT_ANIM_DURATION = 0.7
const THOUGHT_CYCLE_TIME = 0.8

@onready var old_characters = [$Indigena1, $Indigena2, $Indigena3, $Toca]
@onready var modern_characters = [$Moderno1, $Moderno2, $Moderno3, $Predio]

var is_igreja_pressed := false
var is_tv_pressed := false
var is_industria_pressed := false

const TRANSITION_HOLD_TIME := 2.5
var transition_timer: Timer
var transition_done := false


func _ready():
	var initial_state = GlobalAudio.get_audio_state()
	update_audio_buttons(initial_state)
	GlobalAudio.audio_state_changed.connect(update_audio_buttons)
	button_audio_on.pressed.connect(GlobalAudio.toggle_audio_state)
	button_audio_off.pressed.connect(GlobalAudio.toggle_audio_state)
	thought_cycle_timer = Timer.new()
	thought_cycle_timer.wait_time = THOUGHT_CYCLE_TIME
	thought_cycle_timer.one_shot = false
	thought_cycle_timer.timeout.connect(_on_thought_cycle)
	add_child(thought_cycle_timer)
	
	button_to_thought_map = {
		button_igreja: "Cruz",
		button_tv: "Televisao",
		button_industria: "Dinheiro"
	}
	
	for button_node in button_to_thought_map.keys():
		button_node.button_down.connect(_on_button_pressed.bind(button_node))
		button_node.button_up.connect(_on_button_released.bind(button_node))
	
	for m in modern_characters:
		m.visible = false
		m.modulate.a = 0.0

	transition_timer = Timer.new()
	transition_timer.one_shot = true
	transition_timer.wait_time = TRANSITION_HOLD_TIME
	transition_timer.timeout.connect(_on_transition_timer_timeout)
	add_child(transition_timer)
		

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch

		if touch.pressed:
			var btn := _get_institution_button_at_pos(touch.position)
			if btn != null:
				touch_id_to_button[touch.index] = btn
				_on_button_pressed(btn)
		else:
			if touch_id_to_button.has(touch.index):
				var btn2 = touch_id_to_button[touch.index]
				_on_button_released(btn2)
				touch_id_to_button.erase(touch.index)


func _get_institution_button_at_pos(pos: Vector2) -> TextureButton:
	if button_igreja.get_global_rect().has_point(pos):
		return button_igreja
	if button_tv.get_global_rect().has_point(pos):
		return button_tv
	if button_industria.get_global_rect().has_point(pos):
		return button_industria
	return null


func update_audio_buttons(is_on: bool):	
	button_audio_on.visible = is_on
	button_audio_off.visible = not is_on

func _process(delta: float):
	pass

func _on_button_pressed(button_node):
	var thought_name = button_to_thought_map[button_node]
	if not thought_name in active_thought_names:
		active_thought_names.append(thought_name)

		if active_thought_names.size() == 1:
			if thought_animation_tween:
				thought_animation_tween.kill()
			hide_all_thoughts()
			
			current_thought_index = -1 
			_on_thought_cycle() 
			thought_cycle_timer.start()
	_set_button_pressed_state(button_node, true)
	_check_start_transition_timer()


func _on_button_released(button_node):
	var thought_name = button_to_thought_map[button_node]
	if thought_name in active_thought_names:
		active_thought_names.erase(thought_name)

		if active_thought_names.is_empty():
			thought_cycle_timer.stop()
			if thought_animation_tween:
				thought_animation_tween.kill()
			hide_all_thoughts()
		else:
			if current_thought_index >= active_thought_names.size():
				current_thought_index = 0
				
	_set_button_pressed_state(button_node, false)
	_check_stop_transition_timer()


func _set_button_pressed_state(button_node: TextureButton, pressed: bool) -> void:
	if button_node == button_igreja:
		is_igreja_pressed = pressed
	elif button_node == button_tv:
		is_tv_pressed = pressed
	elif button_node == button_industria:
		is_industria_pressed = pressed


func _are_all_three_pressed() -> bool:
	return is_igreja_pressed and is_tv_pressed and is_industria_pressed


func _check_start_transition_timer() -> void:
	if transition_done:
		return
	if _are_all_three_pressed():
		if transition_timer.is_stopped():
			transition_timer.start()  


func _check_stop_transition_timer() -> void:
	if not _are_all_three_pressed() and not transition_timer.is_stopped():
		transition_timer.stop()


func _on_transition_timer_timeout() -> void:
	if _are_all_three_pressed() and not transition_done:
		start_characters_transition()


func start_characters_transition():
	transition_done = true

	if active_thought_names.size() > 0:
		active_thought_names.clear()
		thought_cycle_timer.stop()
		if thought_animation_tween:
			thought_animation_tween.kill()
		hide_all_thoughts()

	var tween := create_tween()
	tween.set_parallel(true)

	for c in old_characters:
		tween.tween_property(c, "modulate:a", 0.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	for m in modern_characters:
		m.visible = true
		m.modulate.a = 0.0
		tween.tween_property(m, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(_on_transition_tween_finished)


func _on_transition_tween_finished() -> void:
	for c in old_characters:
		c.visible = false


func _on_thought_cycle():
	if active_thought_names.is_empty():
		return

	current_thought_index = (current_thought_index + 1) % active_thought_names.size()
	
	if active_thought_names.is_empty():
		return

	var thought_name_to_show = active_thought_names[current_thought_index]
	animate_thought_pop(thought_name_to_show)


func animate_thought_pop(thought_name: String):
	if thought_animation_tween:
		thought_animation_tween.kill()
		
	thought_animation_tween = create_tween()
	thought_animation_tween.set_parallel(true)
	
	for char_sprite in characters:
		var thought_sprite = char_sprite.get_node(thought_name) as Sprite2D
		if not thought_sprite:
			continue
		
		thought_sprite.visible = true
		thought_sprite.modulate.a = 0.0
		thought_sprite.position.y = -60.0  
		thought_sprite.scale = Vector2.ONE
		
		thought_animation_tween.parallel().tween_property(thought_sprite, "modulate:a", 1.0, 
			THOUGHT_ANIM_DURATION * 0.3).set_trans(Tween.TRANS_SINE)
		
		thought_animation_tween.parallel().tween_property(thought_sprite, "scale", Vector2(1.1, 1.1), 
			THOUGHT_ANIM_DURATION * 0.3).set_trans(Tween.TRANS_BACK)
		
		thought_animation_tween.parallel().tween_property(thought_sprite, "position:y", thought_sprite.position.y - 30.0, 
			THOUGHT_ANIM_DURATION * 0.8).set_trans(Tween.TRANS_SINE).set_delay(0.1)
			
		thought_animation_tween.parallel().tween_property(thought_sprite, "modulate:a", 0.0, 
			THOUGHT_ANIM_DURATION * 0.5).set_trans(Tween.TRANS_QUAD).set_delay(THOUGHT_ANIM_DURATION * 0.5)


func hide_all_thoughts():
	for char_sprite in characters:
		for thought_name in button_to_thought_map.values():
			var thought_sprite = char_sprite.get_node(thought_name) as Sprite2D
			if thought_sprite:
				thought_sprite.visible = false
				thought_sprite.modulate.a = 0.0
