extends CharacterBody2D


const max_speed = 500.0
const JUMP_VELOCITY = -700.0
var acceleration = 5 # in frames from 0 to target
var deceleration = 10 # also in frames but constant, that is from max speed to 0

var can_jump = false
var can_wall_jump = false
var can_double_jump = false
var on_r_wall = false
var on_l_wall = false
var gravity_modifier = 2 #this is for variable jump height
var terminal_vel = 1000
var terminal_vel_modifier = 1.0 #this is for wall slides


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func update_player_state():
	if is_on_floor():
		can_jump = true #update with coyote time
		can_double_jump = true
	else:
		can_jump = false
	
	on_l_wall = $wall_check_left.is_colliding()
	on_r_wall = $wall_check_right.is_colliding()

	if on_l_wall or on_r_wall:
		terminal_vel_modifier = 0.1
		can_wall_jump = true
		can_double_jump = true
	else:
		terminal_vel_modifier = 1
		can_wall_jump = false






func _physics_process(delta):
	update_player_state()
	# Add the gravity.
	if not is_on_floor():
		if (velocity.y >= terminal_vel*terminal_vel_modifier):
			velocity.y = lerp(velocity.y,float(terminal_vel*terminal_vel_modifier),0.1)
		else:
			velocity.y += gravity * delta * gravity_modifier
	# Handle Jump, wall_jump, and double jump
	if Input.is_action_just_pressed("jump"): #add jump buffer here
		if can_jump:
			velocity.y = JUMP_VELOCITY
		elif can_wall_jump:
			if on_r_wall && on_l_wall:
				velocity.y = JUMP_VELOCITY
			elif on_l_wall:
				velocity.y = JUMP_VELOCITY
				velocity.x = max_speed
			elif on_r_wall:
				velocity.y = JUMP_VELOCITY
				velocity.x = -max_speed
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false


	var target_vel = Input.get_axis("left", "right") * max_speed
	if target_vel && (abs(velocity.x) < abs(target_vel)):
		if abs(velocity.x) + (max_speed/acceleration) > target_vel:
			velocity.x = target_vel
		else:
			velocity.x += (max_speed/acceleration) * Input.get_axis("left", "right")
	elif velocity.x && (velocity.x != target_vel):
		if abs(velocity.x) > (max_speed/deceleration):
			velocity.x -= ((max_speed/deceleration) * ((abs(velocity.x)/velocity.x)))
		else:
			velocity.x = 0
	move_and_slide()
	
	print(can_wall_jump)
	print(velocity)
	print(gravity)
	

	

