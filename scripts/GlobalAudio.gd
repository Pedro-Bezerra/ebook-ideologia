extends Node

var is_audio_on: bool = true
var scene_manager_node: Node = null 

signal audio_state_changed(is_on: bool)

func set_scene_manager(manager: Node): 
	scene_manager_node = manager
	print("SceneManager registrado em GlobalAudio.")

func toggle_audio_state():
	is_audio_on = not is_audio_on
	
	var narration_bus_index = AudioServer.get_bus_index("Narracao")
	
	AudioServer.set_bus_mute(narration_bus_index, not is_audio_on)
	
	if scene_manager_node != null:
		if not is_audio_on:
			scene_manager_node.page_audio_player.stop() 
		else:
			scene_manager_node.play_page_audio(scene_manager_node.current_page_index)
	
	emit_signal("audio_state_changed", is_audio_on)
	print("Áudio Toggled. Novo estado: ", is_audio_on)

func get_audio_state() -> bool:
	return is_audio_on
