extends CharacterBody3D

@onready var armature = get_node("Armature")
@onready var spring_arm_pivot = get_node("SpringArmPivot")
@onready var spring_arm = get_node("SpringArmPivot/SpringArm3D")
@onready var flashlight = get_node("../DirectionalLight3D")
@onready var raycast = get_node("SpringArmPivot/SpringArm3D/RayCast3D")
@onready var enemy = get_node("../Enemy")
@onready var tables = [get_node("../Enemy/NavigationAgent3D/NavigationRegion3D/map/table1"), \
					   get_node("../Enemy/NavigationAgent3D/NavigationRegion3D/map/table2"), \
					   get_node("../Enemy/NavigationAgent3D/NavigationRegion3D/map/table3"), \
					   get_node("../Enemy/NavigationAgent3D/NavigationRegion3D/map/table4")]
@onready var musicbox = get_node("../Enemy/NavigationAgent3D/NavigationRegion3D/map/musicbox")

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
		# how much we can look up or down
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2, PI/2)


func _physics_process(delta):
	# Interact
	if Input.is_action_just_pressed("Interact"):
		if under_table:	# If the player was already under the table, get out of the table
			spring_arm.position = Vector3(0, 1.785, 0)
			position = last_pos
			under_table = false
		elif raycast.get_collider() != null and raycast.get_collider().get_owner() in tables and \
				position.distance_to(raycast.get_collider().global_position) <= 4:
			# Go under the table
			under_table = true
			spring_arm.position = Vector3(0, 0.2, 0)
			last_pos = position
			position = Vector3(raycast.get_collider().global_position.x, 0, raycast.get_collider().global_position.z)
	elif Input.is_action_pressed("Interact"):	# holding interact
		# looking at the musicbox while holding interact
		if raycast.get_collider() != null and raycast.get_collider().get_owner() == musicbox and \
				position.distance_to(raycast.get_collider().global_position) <= 2:
			musicbox.playing = true
		else:	
			# If you stop looking at the musicbox while holding interact
			musicbox.playing = false
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
		musicbox.playing = false
	
	direction()

	move_and_slide()


func direction():
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
	
	# Direction of the model
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, lerp_val)
		velocity.z = lerp(velocity.z, direction.z * speed, lerp_val)
		# rotating the model
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), lerp_val)
	else:
		velocity.x = lerp(velocity.x, 0.0, lerp_val)
		velocity.z = lerp(velocity.z, 0.0, lerp_val)
	

func _on_area_3d_body_entered(body):
	if body == enemy:
		dead = true


func interact_range_indicator():
	if raycast.is_colliding() and raycast.get_collider():
		if raycast.get_collider().get_owner() in tables and position.distance_to(raycast.get_collider().global_position) <= 4:
			for i in tables:
				if i == raycast.get_collider().get_owner():
					i.get_node("Cube_001/Outline").show()
					musicbox.get_node("Cube/outline").hide()
		elif raycast.get_collider().get_owner() == musicbox and position.distance_to(raycast.get_collider().global_position) <= 2:
			musicbox.get_node("Cube/outline").show()
			for i in tables:
				i.get_node("Cube_001/Outline").hide()
		else:
			for i in tables:
				i.get_node("Cube_001/Outline").hide()
			musicbox.get_node("Cube/outline").hide()
	else:
		for i in tables:
			i.get_node("Cube_001/Outline").hide()
		musicbox.get_node("Cube/outline").hide()
