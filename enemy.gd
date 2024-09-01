extends CharacterBody3D

@onready var armature = get_node("Armature")
@onready var anim_tree = get_node("AnimationTree")
@onready var player = get_node("../Player")
@onready var aggro_timer = get_node("AggroTimer")
@onready var deaggro_timer = get_node("DeaggroTimer")
@onready var passive_timer = get_node("PassiveTimer")
@onready var move_timer = get_node("MoveTimer")

const lerp_val = 0.15

var rng = RandomNumberGenerator.new()

var aggro = false
var speed = 2.0
var flashed = false
var passive = false
var non_aggro_speed = 3.0

var cur_room = 3
var target_room = cur_room
var path = []
var path_idx = 0
@onready var nav = get_node("NavigationAgent3D")

var madness = 1
@onready var madness_timer = get_node("MadnessTimer")

var move_time_min = 2.0
var move_time_max = 5.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	madness_check()


func _physics_process(delta):
	if madness <= 4:
		$"../UI/MadnessLabel".text = "Madness: " + str(madness)
	else:
		$"../UI/MadnessLabel".text = "Madness: MAX"
	
	# Enemy is passive
	if passive:
		speed = 0.0
		velocity = Vector3.ZERO
		$Armature/Skeleton3D/OmniLight3D.light_color = Color(0.149, 0.537, 0)
	# Enemy neutral state
	elif not aggro:
		$Armature/Skeleton3D/OmniLight3D.light_color = Color(255, 255, 255)
		speed = non_aggro_speed
		# Player is near
		if aggro_timer.is_stopped() and position.distance_to(player.position) <= 12 and \
				not player.under_table:
			follow_target(player.position)
			move_timer.stop()
			# Start the aggro timer if the player is too close
			if position.distance_to(player.position) <= 5:
				aggro_timer.start()
		elif not aggro_timer.is_stopped():
			velocity = Vector3.ZERO
		else:		# Player is not near
			if path.size() > 0:
				if path_idx >= path.size():
					pass
				elif global_transform.origin.distance_to(path[path_idx]) < 1:
					path_idx += 1
				else:
					if nav.is_target_reached() and move_timer.is_stopped():		# Target location is reached
						velocity = Vector3.ZERO
						cur_room = target_room
						get_target_room()
						move_timer.wait_time = rng.randf_range(move_time_min, move_time_max)
						move_timer.start()
					elif move_timer.is_stopped():	# After the wait time, move
						follow_target(path[path_idx])
	else:	# Enemy is aggro
		if flashed and madness != 5:
			$Armature/Skeleton3D/OmniLight3D.light_color = Color(1, 1, 0.376)
			speed = 2.0
			if deaggro_timer.is_stopped():
				deaggro_timer.start()
		else:
			$Armature/Skeleton3D/OmniLight3D.light_color = Color(0.313, 0.042, 0)
			speed = 8.0
			deaggro_timer.stop()
			# Kill player if the player is under the table
			if player.under_table and position.distance_to(player.position) <= 3.5:
				player.dead = true
		follow_target(player.global_position)
	
	if position.distance_to(player.position) <= 7:
		$Armature/Skeleton3D/OmniLight3D.light_energy = 1
	else:
		$Armature/Skeleton3D/OmniLight3D.light_energy = 0
	
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / speed)

	move_and_slide()


func follow_target(target_pos):
	var direction = Vector3.ZERO
	direction = (transform.basis * (target_pos - global_transform.origin)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, lerp_val)
		velocity.z = lerp(velocity.z, direction.z * speed, lerp_val)
		# rotating the model
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), lerp_val)
	else:
		velocity.x = lerp(velocity.x, 0.0, lerp_val)
		velocity.z = lerp(velocity.z, 0.0, lerp_val)


func get_room_path(room_pos):
	nav.set_target_position(room_pos)
	path = NavigationServer3D.map_get_path($NavigationAgent3D/NavigationRegion3D.get_navigation_map(), global_transform.origin, room_pos, true)
	path_idx = 0


func get_target_room():
	if cur_room == 1:
		target_room = 3		# Go to room 3
		get_room_path(Vector3(0, 0, 0))
	elif cur_room == 2:
		target_room = 3		# Go to room 3
		get_room_path(Vector3(0, 0, 0))
	elif cur_room == 3:
		var rand_num = rng.randi_range(0, 3)
		if rand_num == 0:	# Go to room 1
			target_room = 1
			get_room_path(Vector3(-14.8, 0, 5.9))
		elif rand_num == 1:	# Go to room 2
			target_room = 2
			get_room_path(Vector3(-14.8, 0, -4.5))
		elif rand_num == 2:	# Go to hall 1
			target_room = 10
			get_room_path(Vector3(3, 0, 14.1))
		else:				# Go to hall 2
			target_room = 11
			get_room_path(Vector3(18, 0, -2.26))
	elif cur_room == 4:
		target_room = 5		# Go to room 5
		get_room_path(Vector3(24.1, 0, 9.4))
	elif cur_room == 5:
		var rand_num = rng.randi_range(0, 2)
		if rand_num == 0:	# Go to hall 2
			target_room = 11
			get_room_path(Vector3(18, 0, -2.26))
		elif rand_num == 1:	# Go to room 4
			target_room = 4
			get_room_path(Vector3(31.4, 0, -1))
		else:				# Go to room 6
			target_room = 6
			get_room_path(Vector3(27, 0, 28))
	elif cur_room == 6:
		var rand_num = rng.randi_range(0, 1)
		if rand_num == 0:	# Go to room 5
			target_room = 5
			get_room_path(Vector3(24.1, 0, 9.4))
		else:				# Go to room 7
			target_room = 7
			get_room_path(Vector3(1.8, 0, 28.3))
	elif cur_room == 7:
		var rand_num = rng.randi_range(0, 3)
		if rand_num == 0:	# Go to room 6
			target_room = 6
			get_room_path(Vector3(27, 0, 28))
		elif rand_num == 1:	# Go to room 8
			target_room = 8
			get_room_path(Vector3(-0.9, 0, 40.1))
		elif rand_num == 2:	# Go to room 9
			target_room = 9
			get_room_path(Vector3(16.1, 0, 32.5))
		else:				# Go to hall 1
			target_room = 10
			get_room_path(Vector3(3, 0, 14.1))
	elif cur_room == 8:
		target_room = 7		# Go to room 7
		get_room_path(Vector3(1.8, 0, 28.3))
	elif cur_room == 9:
		target_room = 7		# Go to room 7
		get_room_path(Vector3(1.8, 0, 28.3))
	elif cur_room == 10:
		var rand_num = rng.randi_range(0, 1)
		if rand_num == 0:	# Go to room 3
			target_room = 3
			get_room_path(Vector3(0, 0, 0))
		else:				# Go to room 7
			target_room = 7
			get_room_path(Vector3(1.8, 0, 28.3))
	else:
		var rand_num = rng.randi_range(0, 1)
		if rand_num == 0:	# Go to room 3
			target_room = 3
			get_room_path(Vector3(0, 0, 0))
		else:				# Go to room 5
			target_room = 5
			get_room_path(Vector3(24.1, 0, 9.4))


func madness_check():
	$"../UI/MadnessProgressBar".value = 0
	if madness == 1:
		aggro_timer.wait_time = 2.5
		deaggro_timer.wait_time = 2.5
		passive_timer.wait_time = 1.5
		madness_timer.wait_time = 20
		non_aggro_speed = 3.0
		move_time_min = 2.0
		move_time_min = 5.0
		$"../UI/MadnessProgressBar".max_value = 20
		$"../WorldEnvironment".environment.fog_density = 0.5
	elif madness == 2:
		aggro_timer.wait_time = 2.0
		deaggro_timer.wait_time = 2.5
		passive_timer.wait_time = 1.0
		madness_timer.wait_time = 20
		non_aggro_speed = 3.5
		move_time_min = 2.0
		move_time_min = 4.5
		$"../UI/MadnessProgressBar".max_value = 20
		$"../WorldEnvironment".environment.fog_density = 0.6
	elif madness == 3:
		aggro_timer.wait_time = 1.5
		deaggro_timer.wait_time = 3.0
		passive_timer.wait_time = 0.5
		madness_timer.wait_time = 15
		non_aggro_speed = 4.5
		move_time_min = 1.5
		move_time_min = 4.5
		$"../UI/MadnessProgressBar".max_value = 15
		$"../WorldEnvironment".environment.fog_density = 0.7
	elif madness == 4:
		aggro_timer.wait_time = 1.0
		deaggro_timer.wait_time = 3.0
		passive_timer.wait_time = 0.5
		madness_timer.wait_time = 15
		non_aggro_speed = 5.0
		move_time_min = 1.5
		move_time_min = 3.5
		$"../UI/MadnessProgressBar".max_value = 15
		$"../WorldEnvironment".environment.fog_density = 0.8
	else:
		aggro_timer.wait_time = 0.1
		deaggro_timer.wait_time = 100.0
		passive_timer.wait_time = 0.1
		non_aggro_speed = 6.0
		madness_timer.stop()
		move_time_min = 0.5
		move_time_min = 1.0
		aggro = true
		$"../UI/MadnessProgressBar".value = 15
		$"../WorldEnvironment".environment.fog_density = 1


func _on_aggro_timer_timeout():
	# Player is too close
	if position.distance_to(player.position) <= 8 and not player.under_table:
		aggro = true
	else:
		get_target_room()
		aggro_timer.stop()


func _on_deaggro_timer_timeout():
	aggro = false
	passive_timer.start()
	passive = true


func _on_passive_timer_timeout():
	$Armature/Skeleton3D/OmniLight3D.light_color = Color(255, 255, 255)
	passive = false
	

func _on_move_timer_timeout():
	# Just for the first move to initialize the navigation
	get_target_room()


func _on_madness_timer_timeout():
	if madness <= 4:
		madness += 1
		madness_check()

