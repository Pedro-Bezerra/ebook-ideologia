extends Control 

@onready var button_audio_on  = $ButtonAudioON
@onready var button_audio_off = $ButtonAudioOFF
@onready var button_valvula   = $ButtonValvula
@onready var fundos_anim      = $Fundos 

@export var rotation_speed: float = 5.0    

var is_user_dragging: bool = false
var drag_started: bool = false
var drag_start_pos: Vector2
var drag_min_distance: float = 8.0        

func _ready():
	var initial_state = GlobalAudio.get_audio_state()
	update_audio_buttons(initial_state)
	GlobalAudio.audio_state_changed.connect(update_audio_buttons)
	button_audio_on.pressed.connect(GlobalAudio.toggle_audio_state)
	button_audio_off.pressed.connect(GlobalAudio.toggle_audio_state)

func update_audio_buttons(is_on: bool):	
	button_audio_on.visible = is_on
	button_audio_off.visible = not is_on


func _process(delta: float) -> void:
	if is_user_dragging:
		if not fundos_anim.is_playing():
			fundos_anim.play("girar_valvula")
		button_valvula.rotation += rotation_speed * delta
	else:
		if fundos_anim.is_playing():
			fundos_anim.stop()
		button_valvula.rotation = 0.0


func _on_button_valvula_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			drag_started = true
			is_user_dragging = false
			drag_start_pos = event.position
		else:
			drag_started = false
			is_user_dragging = false
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			drag_started = true
			is_user_dragging = false
			drag_start_pos = event.position
		else:
			drag_started = false
			is_user_dragging = false
		return

	if (event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0) \
		or (event is InputEventScreenDrag):
		
		var local_pos: Vector2 = event.position
		var rect := Rect2(Vector2.ZERO, button_valvula.size)

		if not rect.has_point(local_pos):
			drag_started = false
			is_user_dragging = false
			return

		if drag_started and not is_user_dragging:
			if local_pos.distance_to(drag_start_pos) >= drag_min_distance:
				is_user_dragging = true

		return
