extends Node

@onready var player = get_node("Player")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if player.dead:
		get_tree().change_scene_to_file("res://death_scene.tscn")


func _on_madness_inc_timer_timeout():
	$UI/MadnessProgressBar.value += 1
