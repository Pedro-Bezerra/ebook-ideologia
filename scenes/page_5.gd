extends Control 

@onready var button_audio_on = $ButtonAudioON
@onready var button_audio_off = $ButtonAudioOFF

@onready var show_button = $Show
@onready var cinema_button = $Cinema
@onready var jogo_button = $Jogo
@onready var futebol_button = $Futebol

@onready var grupo_show = $"Grupo-Show"
@onready var grupo_cinema = $"Grupo-Cinema"
@onready var grupo_jogo = $"Grupo-Jogo"
@onready var grupo_futebol = $"Grupo-Futebol"

@onready var alvo_show = $AlvoShow
@onready var alvo_cinema = $AlvoCinema
@onready var alvo_jogo = $AlvoJogo
@onready var alvo_futebol = $AlvoFutebol

var idle_tweens: Dictionary = {}

const PROTEST_ANGLE: float = 3.0 
const PROTEST_SPEED: float = 0.15 

func _ready():
	var initial_state = GlobalAudio.get_audio_state()
	update_audio_buttons(initial_state)
	GlobalAudio.audio_state_changed.connect(update_audio_buttons)
	button_audio_on.pressed.connect(GlobalAudio.toggle_audio_state)
	button_audio_off.pressed.connect(GlobalAudio.toggle_audio_state)
	show_button.pressed.connect(_on_activity_pressed.bind(show_button, grupo_show, alvo_show))
	cinema_button.pressed.connect(_on_activity_pressed.bind(cinema_button, grupo_cinema, alvo_cinema))
	jogo_button.pressed.connect(_on_activity_pressed.bind(jogo_button, grupo_jogo, alvo_jogo))
	futebol_button.pressed.connect(_on_activity_pressed.bind(futebol_button, grupo_futebol, alvo_futebol))
	
	start_protest_animation(grupo_show)
	start_protest_animation(grupo_cinema)
	start_protest_animation(grupo_jogo)
	start_protest_animation(grupo_futebol)

func update_audio_buttons(is_on: bool):	
	button_audio_on.visible = is_on
	button_audio_off.visible = not is_on

func start_protest_animation(group_node: Node2D):
	var tween = create_tween()
	tween.set_loops() 
	
	tween.set_trans(Tween.TRANS_LINEAR) 
	
	tween.tween_property(group_node, "rotation_degrees", PROTEST_ANGLE, PROTEST_SPEED)
	tween.tween_property(group_node, "rotation_degrees", -PROTEST_ANGLE, PROTEST_SPEED * 2)
	tween.tween_property(group_node, "rotation_degrees", PROTEST_ANGLE, PROTEST_SPEED * 2)
	
	idle_tweens[group_node] = tween

func _on_activity_pressed(button_pressed: TextureButton, group_to_move: Node2D, target_marker: Marker2D):
	
	if idle_tweens.has(group_to_move):
		var idle_tween: Tween = idle_tweens[group_to_move]
		idle_tween.kill()
		idle_tweens.erase(group_to_move)
		
		group_to_move.rotation_degrees = 0.0
	
	button_pressed.disabled = true
	
	var move_tween = create_tween()
	move_tween.tween_property(group_to_move, "global_position", target_marker.global_position, 1.0)\
		 .set_trans(Tween.TRANS_QUAD)\
		 .set_ease(Tween.EASE_OUT)
