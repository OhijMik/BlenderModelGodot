extends CharacterBody3D

@onready var armature = get_node("Armature")
@onready var anim_tree = get_node("AnimationTree")
@onready var player = get_node("../../Player")
@onready var aggro_timer = get_node("AggroTimer")
@onready var deaggro_timer = get_node("DeaggroTimer")

const lerp_val = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var aggro = false
var speed = 2.0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if not aggro:
		$Armature/Skeleton3D/OmniLight3D.light_color = Color(255, 255, 255)
		speed = 2.0
		if aggro_timer.is_stopped():
			follow_player()
			if position.distance_to(player.position) <= 4:
				aggro_timer.start()
		else:
			velocity = Vector3.ZERO
	else:
		$Armature/Skeleton3D/OmniLight3D.light_color = Color(91, 0, 0)
		speed = 10.0
		follow_player()
	
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / speed)

	move_and_slide()


func follow_player():
	var direction = Vector3.ZERO
	#direction = (transform.basis * Vector3(player.position.x - position.x, 0, player.position.z - position.z)).normalized()
	
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
