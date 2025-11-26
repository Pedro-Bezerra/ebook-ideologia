extends Control

@export var page_scenes: Array[PackedScene] = [
	preload("res://scenes/Page1.tscn"), 
	preload("res://scenes/Page2.tscn"),
	preload("res://scenes/Page3.tscn"),
	preload("res://scenes/Page4.tscn"),
	preload("res://scenes/Page5.tscn"),
	preload("res://scenes/Page6.tscn"),
	preload("res://scenes/Page7.tscn"),
	preload("res://scenes/Page8.tscn"),
]

var current_page_index: int = 0
var current_page: Node = null

var page_audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(page_audio_player)
	page_audio_player.bus = "Narracao"  
	GlobalAudio.set_scene_manager(self)
	change_page_to_index(0)

func change_page_to_index(index: int):
	if index < 0 or index >= page_scenes.size():
		print("Índice de página inválido: ", index)
		return

	current_page_index = index
	if current_page != null:
		disconnect_page_buttons(current_page)
		current_page.queue_free() 
	
	var new_page_scene = page_scenes[current_page_index]
	current_page = new_page_scene.instantiate()
	add_child(current_page)
	connect_page_buttons(current_page)
	play_page_audio(current_page_index)
	

func play_page_audio(index: int):
	var page_number = index + 1
	var audio_path = "res://audios/Page" + str(page_number) + ".mp3"
	
	var audio_stream = load(audio_path)
	
	if audio_stream != null:
		page_audio_player.stream = audio_stream
		page_audio_player.play()
		print("Tocando áudio: ", audio_path)
	else:
		print("ERRO: Falha ao carregar o arquivo de áudio: ", audio_path)
		page_audio_player.stop()

func connect_page_buttons(page_node: Node):
	var button_next = page_node.find_child("ButtonNext", true) 
	var button_previous = page_node.find_child("ButtonPrevious", true) 

	if button_next:
		print("Botão Next encontrado e CONECTADO na página: ", current_page_index)
		button_next.pressed.connect(go_to_next_page)
	else:
		print("ERRO: Botão Next não encontrado na página: ", current_page_index)

	if button_previous:
		print("Botão Previous encontrado e CONECTADO na página: ", current_page_index)
		button_previous.pressed.connect(go_to_previous_page)
	else:
		print("ERRO: Botão Previous não encontrado na página: ", current_page_index)

func disconnect_page_buttons(page_node: Node):
	var button_next = page_node.find_child("ButtonNext")
	var button_previous = page_node.find_child("ButtonPrevious")
	if button_next and button_next.pressed.is_connected(go_to_next_page):
		button_next.pressed.disconnect(go_to_next_page)
	if button_previous and button_previous.pressed.is_connected(go_to_previous_page):
		button_previous.pressed.disconnect(go_to_previous_page)

func go_to_next_page():
	if current_page_index == page_scenes.size() - 1:
		change_page_to_index(0)
	else:
		change_page_to_index(current_page_index + 1)

func go_to_previous_page():
	change_page_to_index(current_page_index - 1)
