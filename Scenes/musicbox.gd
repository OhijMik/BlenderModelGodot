extends Node3D

@onready var model_anim = get_node("AnimationPlayer")
@onready var handle_anim = get_node("HandleAnimationPlayer")
@onready var timer = get_node("PlayTimer")
@onready var bar = get_node("../../../../../UI/SongProgressBar")

var playing = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(playing)
	bar.value = 2.5 - timer.time_left
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


func _on_play_timer_timeout():
	model_anim.stop()
	handle_anim.stop()
	visible = false
	playing = false
	bar.hide()
