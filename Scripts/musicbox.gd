extends Node3D

@onready var model_anim = get_node("AnimationPlayer")
@onready var handle_anim = get_node("HandleAnimationPlayer")
@onready var fade_anim = get_node("FadeAnimationPlayer")
@onready var anim_timer = get_node("PlayTimer")
@onready var fade_timer = get_node("FadeTimer")
@onready var bar = get_node("../../../../../UI/SongProgressBar")

var rng = RandomNumberGenerator.new()

var playing = false
var fading = false

var cur_pos_num = 1


func _ready():
	# musicbox_spawn()
	pass


func _process(delta):
	bar.value = 5.0 - anim_timer.time_left	# Changing the bar value
	
	if playing and anim_timer.is_stopped() and not fading:
		anim_timer.start()
		model_anim.play("model")
		handle_anim.play("handle")
		bar.show()
	elif not playing:
		anim_timer.stop()
		model_anim.stop()
		handle_anim.stop()
		bar.hide()


func musicbox_spawn():
	var rand_num = rng.randi_range(1, 7)
	while rand_num == cur_pos_num:
		rand_num = rng.randi_range(1, 2)
	if rand_num == 1:
		position = Vector3(3.7, 1.15, -7.4)
		rotation.y = PI/2
	elif rand_num == 2:
		position = Vector3(-18.5, 0.05, -6.6)
		rotation.y = PI
	elif rand_num == 3:
		position = Vector3(-17.8, 0.05, 9)
		rotation.y = 5*PI/4
	elif rand_num == 4:
		position = Vector3(30.3, 1.15, -3.7)
		rotation.y = PI/2
	elif rand_num == 5:
		position = Vector3(26.4, 1.15, 35)
		rotation.y = 3*PI/2
	elif rand_num == 6:
		position = Vector3(18, 0.05, 36.7)
		rotation.y = 7*PI/4
	elif rand_num == 7:
		position = Vector3(0, 1.15, 41.4)
		rotation.y = PI/2
	cur_pos_num = rand_num


func _on_play_timer_timeout():
	model_anim.stop()
	handle_anim.stop()
	playing = false
	fading = true
	bar.hide()
	fade_timer.start()
	fade_anim.play("fade")


func _on_fade_timer_timeout():
	position = Vector3(0, 0, 10)
	fade_anim.stop()
	scale = Vector3(0.59, 0.59, 0.59)
	global.required_musicbox -= 1
	musicbox_spawn()
