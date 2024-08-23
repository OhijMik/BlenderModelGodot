extends CharacterBody3D

@onready var armature = get_node("Armature")
@onready var anim_tree = get_node("AnimationTree")
@onready var player = get_node("../Player")
@onready var aggro_timer = get_node("AggroTimer")
@onready var deaggro_timer = get_node("DeaggroTimer")
@onready var passive_timer = get_node("PassiveTimer")

const lerp_val = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var aggro = false
var speed = 2.0
var flashed = false
var passive = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if passive:
		speed = 0.0
		velocity = Vector3.ZERO
		$Armature/Skeleton3D/OmniLight3D.light_color = Color(0.149, 0.537, 0)
	elif not aggro:
		$Armature/Skeleton3D/OmniLight3D.light_color = Color(255, 255, 255)
		speed = 2.0
		if aggro_timer.is_stopped():
			follow_player()
			if position.distance_to(player.position) <= 4:
				aggro_timer.start()
		else:
			velocity = Vector3.ZERO
	else:
		if flashed:
			$Armature/Skeleton3D/OmniLight3D.light_color = Color(1, 1, 0.376)
			speed = 2.0
			if deaggro_timer.is_stopped():
				deaggro_timer.start()
		else:
			$Armature/Skeleton3D/OmniLight3D.light_color = Color(0.313, 0.042, 0)
			speed = 8.0
			deaggro_timer.stop()
		follow_player()
	
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / speed)

	move_and_slide()


func follow_player():
	var direction = Vector3.ZERO
	direction = (transform.basis * Vector3(player.position.x - position.x, 0, player.position.z - position.z)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, lerp_val)
		velocity.z = lerp(velocity.z, direction.z * speed, lerp_val)
		# rotating the model
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), lerp_val)
	else:
		velocity.x = lerp(velocity.x, 0.0, lerp_val)
		velocity.z = lerp(velocity.z, 0.0, lerp_val)


func _on_aggro_timer_timeout():
	if position.distance_to(player.position) <= 6:
		aggro = true
	else:
		aggro_timer.stop()


func _on_deaggro_timer_timeout():
	aggro = false
	passive_timer.start()
	passive = true


func _on_passive_timer_timeout():
	$Armature/Skeleton3D/OmniLight3D.light_color = Color(255, 255, 255)
	passive = false
	
