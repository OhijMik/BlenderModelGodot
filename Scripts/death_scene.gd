extends Node3D


func _on_timer_timeout():
	get_tree().change_scene_to_file("res://end_scene.tscn")
