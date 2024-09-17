extends Node2D


func _on_normal_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu_scene.tscn")
