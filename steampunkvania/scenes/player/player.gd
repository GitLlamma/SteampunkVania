extends CharacterBody2D


const max_speed = 500.0
const JUMP_VELOCITY = -400.0
var acceleration = 10 # in frames from 0 to target
var deceleration = 10 # also in frames but constant, that is from max speed to 0

var can_jump = false
var can_wall_jump = false
var can_double_jump = false
var on_r_wall = false
var on_l_wall = false
var gravity_modifier = 2 #this is for variable jump height
var terminal_vel = 1000
var terminal_vel_modifier = 1.0 #this is for wall slides
var frames_since_off_floor = 0
var frames_since_last_jumped = 0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func update_player_state():
	if is_on_floor():
		frames_since_off_floor = 0
		can_jump = true #update with coyote time
		can_double_jump = true
	else:
		frames_since_off_floor += 1
		frames_since_last_jumped += 1
	
	if frames_since_off_floor <= 6:
		can_jump = true
	else:
		can_jump = false
	
	if frames_since_last_jumped <= 6 && Input.is_action_pressed("jump"):
		velocity.y += JUMP_VELOCITY/5
	
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
			frames_since_last_jumped = 0
		elif can_wall_jump:
			frames_since_last_jumped = 0
			if on_r_wall && on_l_wall:
				velocity.y = JUMP_VELOCITY
			elif on_l_wall:
				velocity.y = JUMP_VELOCITY
				velocity.x = max_speed * 2.2
			elif on_r_wall:
				velocity.y = JUMP_VELOCITY
				velocity.x = -max_speed * 2.2
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			frames_since_last_jumped = 0
			can_double_jump = false
	if Input.is_action_just_pressed("down"):
		position.y += 1
	

	var target_vel = Input.get_axis("left", "right") * max_speed
	if target_vel && (abs(velocity.x) < abs(target_vel)):
		if abs(velocity.x) + (max_speed/acceleration) > abs(target_vel):
			velocity.x = target_vel
		else:
			velocity.x += (max_speed/acceleration) * Input.get_axis("left", "right")
	elif velocity.x && (velocity.x != target_vel):
		if abs(velocity.x) > (max_speed/deceleration):
			velocity.x -= ((max_speed/deceleration) * ((abs(velocity.x)/velocity.x)))
		else:
			velocity.x = 0
	print(velocity)
	print(gravity_modifier)

func _process(delta):
	move_and_slide()
	

	

