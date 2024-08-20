extends CharacterBody3D

@onready var armature = get_node("Armature")
@onready var anim_tree = get_node("AnimationTree")
@onready var player = get_node("../../Player")
@onready var agro_timer = get_node("AgroTimer")

const SPEED = 3.0

const lerp_val = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var agro = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if not agro:
		if agro_timer.is_stopped():
			follow_player()
			if position.distance_to(player.position) <= 4:
				agro_timer.start()
		else:
			velocity = Vector3.ZERO
	else:
		follow_player()
	
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / SPEED)
	print(agro_timer.time_left)
	move_and_slide()


func follow_player():
	var direction = Vector3.ZERO
	direction = (transform.basis * Vector3(player.position.x - position.x, 0, player.position.z - position.z)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, lerp_val)
		velocity.z = lerp(velocity.z, direction.z * SPEED, lerp_val)
		# rotating the model
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), lerp_val)
	else:
		velocity.x = lerp(velocity.x, 0.0, lerp_val)
		velocity.z = lerp(velocity.z, 0.0, lerp_val)


func _on_agro_timer_timeout():
	if position.distance_to(player.position) <= 4:
		agro = true
	else:
		agro_timer.stop()
