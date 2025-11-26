extends Control

@onready var button_audio_on = $ButtonAudioON
@onready var button_audio_off = $ButtonAudioOFF

@onready var personagem = $Personagem
@onready var joystick_visual = $JoystickVirtual 

@onready var lista_imagens = [
	$ImgFeliz1, $ImgFeliz2, $ImgFeliz3, $ImgFeliz4
]

var nomes_areas_feliz = ["Feliz1", "Feliz2", "Feliz3", "Feliz4"]

var game_active = true

func _ready():
	var initial_state = GlobalAudio.get_audio_state()
	update_audio_buttons(initial_state)
	GlobalAudio.audio_state_changed.connect(update_audio_buttons)
	button_audio_on.pressed.connect(GlobalAudio.toggle_audio_state)
	button_audio_off.pressed.connect(GlobalAudio.toggle_audio_state)
	
	for img in lista_imagens:
		if img: img.visible = false
	
	for i in range(nomes_areas_feliz.size()):
		var nome_do_no = nomes_areas_feliz[i]
		var no_area = get_node_or_null(nome_do_no)
		if no_area:
			if not no_area.body_entered.is_connected(_on_vitoria):
				no_area.body_entered.connect(_on_vitoria.bind(i))

func _on_vitoria(body, indice_imagem):
	if game_active and body.name == "Personagem":
		print("Vitória alcançada no final número: ", indice_imagem + 1)
		
		game_active = false
		
		if personagem:
			personagem.can_move = false
			
		if joystick_visual:
			joystick_visual.stop() 
		
		if indice_imagem < lista_imagens.size():
			lista_imagens[indice_imagem].visible = true

func update_audio_buttons(is_on: bool):	
	button_audio_on.visible = is_on
	button_audio_off.visible = not is_on
