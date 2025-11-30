extends Control

func _on_start_button_pressed():
	PlayerData.reset() 
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
