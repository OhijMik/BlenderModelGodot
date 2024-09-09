extends Node

@onready var player = get_node("Player")


func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if global.required_musicbox <= 0:
		get_tree().change_scene_to_file("res://Scenes/win_scene.tscn")
	
	if player.dead:
		get_tree().change_scene_to_file("res://Scenes/death_scene.tscn")


func _on_madness_inc_timer_timeout():
	$UI/MadnessProgressBar.value += 1
