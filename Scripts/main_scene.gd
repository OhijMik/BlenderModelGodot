extends Node

@onready var player = get_node("Player")
@onready var enemy = get_node("Enemy")

@onready var black_screen_wait_timer = get_node("UI/BlackScreen/BlackScreenWaitTimer")


func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if global.required_musicbox <= 0:
		get_tree().change_scene_to_file("res://Scenes/win_scene.tscn")
	
	if player.dead:
		$UI/BlackScreen/BlackScreenLingeringTimer.stop()
		black_screen_wait_timer.stop()
		get_tree().change_scene_to_file("res://Scenes/death_scene.tscn")
	
	if player.position.distance_to(enemy.position) <= 2:
		black_screen_wait_timer.wait_time = 0.1
	elif player.position.distance_to(enemy.position) <= 3:
		black_screen_wait_timer.wait_time = 0.25
	elif player.position.distance_to(enemy.position) <= 5:
		black_screen_wait_timer.wait_time = 0.4
	elif player.position.distance_to(enemy.position) <= 6:
		black_screen_wait_timer.wait_time = 0.6
	elif player.position.distance_to(enemy.position) <= 7:
		black_screen_wait_timer.wait_time = 0.8
	
	if player.position.distance_to(enemy.position) <= 7 and \
			black_screen_wait_timer.is_stopped():
		$UI/BlackScreen/BlackScreen.show()
		$UI/BlackScreen/BlackScreenLingeringTimer.start()
		black_screen_wait_timer.start()


func _on_madness_inc_timer_timeout():
	$UI/Madness/MadnessProgressBar.value += 1


func _on_black_screen_lingering_timer_timeout():
	$UI/BlackScreen/BlackScreen.hide()
