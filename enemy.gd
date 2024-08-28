extends CharacterBody3D

@onready var armature = get_node("Armature")
@onready var anim_tree = get_node("AnimationTree")
@onready var player = get_node("../Player")
@onready var aggro_timer = get_node("AggroTimer")
@onready var deaggro_timer = get_node("DeaggroTimer")
@onready var passive_timer = get_node("PassiveTimer")

const lerp_val = 0.15

var aggro = false
var speed = 2.0
var flashed = false
var passive = false

var room = 3
var room_rng = RandomNumberGenerator.new()
var path = []
var path_idx = 0
@onready var nav = get_node("NavigationAgent3D")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Enemy is passive
	if passive:
		speed = 0.0
		velocity = Vector3.ZERO
		$Armature/Skeleton3D/OmniLight3D.light_color = Color(0.149, 0.537, 0)
	# Enemy neutral state
	elif not aggro:
		$Armature/Skeleton3D/OmniLight3D.light_color = Color(255, 255, 255)
		speed = 3.0
		# Player is near
		if aggro_timer.is_stopped() and position.distance_to(player.position) <= 0: # 8
			follow_target(global_position)
			# Start the aggro timer if the player is too close
			if position.distance_to(player.position) <= 4:
				aggro_timer.start()
		else:
			# Player is not near
			# _room_movement()
			#nav.get_current_navigation_path()
			#nav.set_navigation_map($NavigationAgent3D/NavigationRegion3D.get_region_rid())
			if path.size() > 0:
				if path_idx >= path.size():
					pass
				elif global_transform.origin.distance_to(path[path_idx]) < 1:
					path_idx += 1
				else:
					#var direction = path[path_idx] - global_transform.origin
					#velocity = direction.normalized() * speed
					#look_at(target_room)
					print(path[path_idx])
					follow_target(path[path_idx])
	else:	# Enemy is aggro
		if flashed:
			$Armature/Skeleton3D/OmniLight3D.light_color = Color(1, 1, 0.376)
			speed = 2.0
			if deaggro_timer.is_stopped():
				deaggro_timer.start()
		else:
			$Armature/Skeleton3D/OmniLight3D.light_color = Color(0.313, 0.042, 0)
			speed = 9.0
			deaggro_timer.stop()
			# Kill player if the player is under the table
			if player.under_table and position.distance_to(player.position) <= 3.5:
				player.dead = true
		follow_target(player.global_position)
	
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


func _room_movement():
	if room == 3:
		var rand_num = room_rng.randi_range(0, 3)
		if rand_num == 0:
			pass


func _on_aggro_timer_timeout():
	# Player is too close
	if position.distance_to(player.position) <= 5.5:
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
	

func _on_move_timer_timeout():
	get_room_path(player.global_position)
