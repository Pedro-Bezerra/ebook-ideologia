extends Control 

@onready var button_audio_on = $ButtonAudioON
@onready var button_audio_off = $ButtonAudioOFF

@onready var drop_zone: Area2D = $DropZone
@onready var visor_verde: Area2D = $VisorVerde
@onready var visor_vermelho: Area2D = $VisorVermelho
@onready var anim_positiva: AnimatedSprite2D = $AnimPositiva
@onready var anim_negativa: AnimatedSprite2D = $AnimNegatva

var dragging_item = null
var green_start_pos: Vector2
var red_start_pos: Vector2
var active_view = "none" 


func _ready():
	var initial_state = GlobalAudio.get_audio_state()
	update_audio_buttons(initial_state)
	GlobalAudio.audio_state_changed.connect(update_audio_buttons)
	button_audio_on.pressed.connect(GlobalAudio.toggle_audio_state)
	button_audio_off.pressed.connect(GlobalAudio.toggle_audio_state)

	await ready
	await get_tree().process_frame 
	
	green_start_pos = visor_verde.global_position
	red_start_pos = visor_vermelho.global_position
	
	anim_positiva.hide()
	anim_negativa.hide()

	visor_verde.input_event.connect(_on_visor_input.bind(visor_verde))
	visor_vermelho.input_event.connect(_on_visor_input.bind(visor_vermelho))
	
	print("--- Page 2 Pronta! Visores conectados. ---")

func update_audio_buttons(is_on: bool):	
	button_audio_on.visible = is_on
	button_audio_off.visible = not is_on

func _on_visor_input(viewport, event, shape_idx, visor):
	print("!!! CLIQUE DETECTADO NO VISOR: ", visor.name)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("Começando a arrastar: ", visor.name)
			
			dragging_item = visor
			visor.get_parent().move_child(visor, -1)
			
			if visor == visor_verde and active_view == "negative":
				set_view("none")
			elif visor == visor_vermelho and active_view == "positive":
				set_view("none")
		else:
			print("Soltou o item: ", visor.name)
			
			if dragging_item == visor:
				dragging_item = null
				
				if drop_zone.overlaps_area(visor):
					if visor == visor_verde:
						set_view("positive")
					else:
						set_view("negative")
				else:
					if (visor == visor_verde and active_view == "positive") or \
					   (visor == visor_vermelho and active_view == "negative"):
						set_view("none")
					else:
						move_visor_to_start(visor)

func _process(delta):
	if dragging_item:
		dragging_item.global_position = get_global_mouse_position()

func set_view(view_type):
	active_view = view_type
	
	if view_type == "positive":
		anim_positiva.show()
		anim_positiva.play("play") 
		anim_negativa.hide()
		anim_negativa.stop()
		
		snap_visor_to_dropzone(visor_verde)
		move_visor_to_start(visor_vermelho)
		
	elif view_type == "negative":
		anim_negativa.show()
		anim_negativa.play("play") 
		anim_positiva.hide()
		anim_positiva.stop()
		
		snap_visor_to_dropzone(visor_vermelho)
		move_visor_to_start(visor_verde)
		
	elif view_type == "none":
		anim_positiva.hide()
		anim_positiva.stop()
		anim_negativa.hide()
		anim_negativa.stop()
		
		move_visor_to_start(visor_verde)
		move_visor_to_start(visor_vermelho)

func move_visor_to_start(visor):
	var start_pos = green_start_pos if visor == visor_verde else red_start_pos
	var tween = create_tween().set_parallel(true)
	tween.tween_property(visor, "global_position", start_pos, 0.3).set_trans(Tween.TRANS_SINE)

func snap_visor_to_dropzone(visor):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(visor, "global_position", drop_zone.global_position, 0.2).set_trans(Tween.TRANS_SINE)
