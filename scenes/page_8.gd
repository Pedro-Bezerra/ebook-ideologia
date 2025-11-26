extends Control

@onready var button_audio_on = $ButtonAudioON
@onready var button_audio_off = $ButtonAudioOFF

func _ready():
	var initial_state = GlobalAudio.get_audio_state()
	update_audio_buttons(initial_state)
	GlobalAudio.audio_state_changed.connect(update_audio_buttons)
	button_audio_on.pressed.connect(GlobalAudio.toggle_audio_state)
	button_audio_off.pressed.connect(GlobalAudio.toggle_audio_state)
	

func update_audio_buttons(is_on: bool):	
	button_audio_on.visible = is_on
	button_audio_off.visible = not is_on
