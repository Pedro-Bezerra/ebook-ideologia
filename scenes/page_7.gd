extends Control

@onready var button_audio_on = $ButtonAudioON
@onready var button_audio_off = $ButtonAudioOFF
@onready var button_video = $ButtonVideo

@onready var button_vitoria = $ButtonVitoria
@onready var button_hypolito = $ButtonHypolito
@onready var video_player = $Panel/VideoStreamPlayer

const VIDEO_PADRAO = preload("res://videos/intro.ogv")
const VIDEO_VITORIA = preload("res://videos/eliminacao_vitoria.ogv")
const VIDEO_HYPOLITO = preload("res://videos/eliminacao_hypolito.ogv")

var video_padrao_terminado: bool = false

func _ready():
	var initial_state = GlobalAudio.get_audio_state()
	update_audio_buttons(initial_state)
	GlobalAudio.audio_state_changed.connect(update_audio_buttons)
	button_audio_on.pressed.connect(GlobalAudio.toggle_audio_state)
	button_audio_off.pressed.connect(GlobalAudio.toggle_audio_state)

	button_video.pressed.connect(iniciar_video_padrao)
	button_vitoria.pressed.connect(start_video.bind("vitoria"))
	button_hypolito.pressed.connect(start_video.bind("hypolito"))
	video_player.finished.connect(_on_video_player_finished)
	
	resetar_para_estado_inicial()

func resetar_para_estado_inicial():
	video_player.stop()
	video_player.stream = null 
	
	button_vitoria.hide() 
	button_hypolito.hide()
	button_video.show()
	
	video_padrao_terminado = false 

func iniciar_video_padrao():
	if video_padrao_terminado:
		return
		
	button_video.hide() 
	video_player.stream = VIDEO_PADRAO
	video_player.play()

func update_audio_buttons(is_on: bool):
	button_audio_on.visible = is_on
	button_audio_off.visible = not is_on
	
func start_video(video_id: String):
	if not video_padrao_terminado:
		print("Ainda não é hora de escolher o vídeo.")
		return
		
	button_vitoria.hide()
	button_hypolito.hide()
	
	match video_id:
		"vitoria":
			video_player.stream = VIDEO_VITORIA
		"hypolito":
			video_player.stream = VIDEO_HYPOLITO
		_:
			print("ERRO: ID de vídeo desconhecido.")
			button_vitoria.show() 
			button_hypolito.show()
			return

	video_player.play()

func _on_video_player_finished():
	if not video_padrao_terminado:
		video_padrao_terminado = true
		video_player.stop() 
		button_vitoria.show()
		button_hypolito.show()
	else:
		resetar_para_estado_inicial()
