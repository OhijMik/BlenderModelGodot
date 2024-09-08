extends Node3D

@onready var model_anim = get_node("AnimationPlayer")
@onready var handle_anim = get_node("HandleAnimationPlayer")
@onready var timer = get_node("PlayTimer")
@onready var bar = get_node("../../../../../UI/SongProgressBar")

var rng = RandomNumberGenerator.new()

var playing = false

var cur_pos_num = 1


func _process(delta):
	bar.value = 5.0 - timer.time_left	# Changing the bar value
	if playing and timer.is_stopped():
		timer.start()
		model_anim.play("model")
		handle_anim.play("handle")
		bar.show()
	elif not playing:
		timer.stop()
		model_anim.stop()
		handle_anim.stop()
		bar.hide()


func musicbox_spawn():
	var rand_num = rng.randi_range(1, 2)
	while rand_num == cur_pos_num:
		rand_num = rng.randi_range(1, 2)
	if rand_num == 1:
		position = Vector3(3.7, 1.15, -7.4)
		rotation.y = PI/2
		cur_pos_num = 1
	elif rand_num == 2:
		position = Vector3(-18.5, 0.05, -6.6)
		rotation.y = PI
		cur_pos_num = 2


func _on_play_timer_timeout():
	model_anim.stop()
	handle_anim.stop()
	playing = false
	bar.hide()
	position = Vector3(0, 0, 10)
	musicbox_spawn()
