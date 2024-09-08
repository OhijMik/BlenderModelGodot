extends Node

@onready var player = get_node("Player")


func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if player.dead:
		get_tree().change_scene_to_file("res://Scenes/death_scene.tscn")


func _on_madness_inc_timer_timeout():
	$UI/MadnessProgressBar.value += 1
