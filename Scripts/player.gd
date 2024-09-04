extends CharacterBody3D

@onready var armature = get_node("Armature")
@onready var spring_arm_pivot = get_node("SpringArmPivot")
@onready var spring_arm = get_node("SpringArmPivot/SpringArm3D")
@onready var flashlight = get_node("../DirectionalLight3D")
@onready var raycast = get_node("SpringArmPivot/SpringArm3D/RayCast3D")
@onready var enemy = get_node("../Enemy")
@onready var tables = [get_node("../Enemy/NavigationAgent3D/NavigationRegion3D/map/Table1"), \
					   get_node("../Enemy/NavigationAgent3D/NavigationRegion3D/map/Table2")]

const JUMP_VELOCITY = 4.5
const lerp_val = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 5.0
var dead = false
var under_table = false
var last_pos

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	# Mouse movement
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * .005)
		spring_arm.rotate_x(-event.relative.y * .005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)


func _physics_process(delta):
	# Flashlight rotation
	flashlight.rotation.y = spring_arm_pivot.rotation.y + 135
	flashlight.rotation.x = spring_arm_pivot.rotation.x
	flashlight.rotation.z = spring_arm_pivot.rotation.z
	
	# Direction
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	raycast.add_exception($".")
	interact_range_indicator()
	
	# Interact
	if Input.is_action_just_pressed("Interact"):
		if under_table:	# If the player was already under the table, get out of the table
			spring_arm.position = Vector3(0, 1.785, 0)
			position = last_pos
			under_table = false
		elif raycast.is_colliding() and "Table" in raycast.get_collider().name and \
			position.distance_to(raycast.get_collider().global_position) <= 3.5:
			# Go under the table
			under_table = true
			spring_arm.position = Vector3(0, 0.2, 0)
			last_pos = position
			position = Vector3(raycast.get_collider().global_position.x, 0, raycast.get_collider().global_position.z)
	elif Input.is_action_pressed("Flashlight"):		# Flashlight
		flashlight.light_energy = 0.05
		speed = 2.0
		if raycast.is_colliding() and enemy == raycast.get_collider():
			enemy.flashed = true
		else:
			enemy.flashed = false
	else:
		flashlight.light_energy = 0
		speed = 5.0
		enemy.flashed = false
	
	# Direction of the model
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, lerp_val)
		velocity.z = lerp(velocity.z, direction.z * speed, lerp_val)
		# rotating the model
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), lerp_val)
	else:
		velocity.x = lerp(velocity.x, 0.0, lerp_val)
		velocity.z = lerp(velocity.z, 0.0, lerp_val)

	move_and_slide()


func _on_area_3d_body_entered(body):
	if body == enemy:
		dead = true


func interact_range_indicator():
	if raycast.is_colliding():
		if "Table" in raycast.get_collider().name and position.distance_to(raycast.get_collider().global_position) <= 3.5:
			for i in range(1, len(tables) + 1):
				if "Table" + str(i) in raycast.get_collider().get_parent().name:
					var outline_path = "../Enemy/NavigationAgent3D/NavigationRegion3D/map/" + "Table" + str(i) +"/TableStaticBody/OutlineMeshInstance3D"
					get_node(outline_path).show()
		else:
			for i in range(1, len(tables) + 1):
				var outline_path = "../Enemy/NavigationAgent3D/NavigationRegion3D/map/" + "Table" + str(i) +"/TableStaticBody/OutlineMeshInstance3D"
				get_node(outline_path).hide()
