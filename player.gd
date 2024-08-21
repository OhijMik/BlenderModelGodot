extends CharacterBody3D

@onready var armature = get_node("Armature")
@onready var spring_arm_pivot = get_node("SpringArmPivot")
@onready var spring_arm = get_node("SpringArmPivot/SpringArm3D")
@onready var anim_tree = get_node("AnimationTree")
@onready var flashlight = get_node("../DirectionalLight3D")
@onready var raycast = get_node("SpringArmPivot/SpringArm3D/RayCast3D")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const lerp_val = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var num = 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * .005)
		spring_arm.rotate_x(-event.relative.y * .005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)


func _physics_process(delta):
	raycast.add_exception($".")
	if raycast.is_colliding():
		print(raycast.get_collider())
	
	flashlight.rotation.y = spring_arm_pivot.rotation.y + 135
	flashlight.rotation.x = spring_arm_pivot.rotation.x
	flashlight.rotation.z = spring_arm_pivot.rotation.z
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)

	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, lerp_val)
		velocity.z = lerp(velocity.z, direction.z * SPEED, lerp_val)
		# rotating the model
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), lerp_val)
	else:
		velocity.x = lerp(velocity.x, 0.0, lerp_val)
		velocity.z = lerp(velocity.z, 0.0, lerp_val)
	
	if Input.is_action_pressed("Flashlight"):
		flashlight.light_energy = 0.01
		armature.rotation.y = lerp_angle(spring_arm_pivot.rotation.y, atan2(-velocity.x, -velocity.z), lerp_val)
	else:
		flashlight.light_energy = 0
	
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / SPEED)

	move_and_slide()
