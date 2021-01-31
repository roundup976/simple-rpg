extends KinematicBody2D

# Player movement speed
export var speed = 75

# Player dragging flag/evnt for mouse movement
var drag_enabled = false

# The last direction the player was facing
var last_direction = Vector2(0, 1)

# If the attack animation is playing (since animate player runs continuously)
var attack_playing = false

func _physics_process(delta):
	# Get player input
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
		
	# Apply movement
	var movement = speed * direction * delta
	
	# If dragging enabled, use mouse position to calculate movement
	if drag_enabled:
		var new_position = get_global_mouse_position()
		movement = new_position - position
		if movement.length() > (speed * delta):
			movement = speed * delta * movement.normalized()
			
	# Slow movement if also attacking
	if attack_playing:
		movement = 0.5 * movement
		
	move_and_collide(movement)
	
	if drag_enabled:
		if not attack_playing:
			animate_player(movement)
	else:
		# Annimate player based on direction when not attacking
		if not attack_playing:
			animate_player(direction)
	
	
func animate_player(direction: Vector2):
	if direction != Vector2.ZERO:
		# update last_direction gradually to eliminate stick bounce
		last_direction = 0.5 * last_direction + 0.5 * direction
		# Choose walk animation based on direction of movement
		var animation = get_animation_direction(last_direction) + "_walk"
		# Set animation frame rate for controller joystick use
		$Sprite.frames.set_animation_speed(animation, 2+8*direction.length())
		# Play the walk animation
		$Sprite.play(animation)
	else:
		# Choose the idle animation based on last movement direction
		var animation = get_animation_direction(last_direction) + "_idle"
		# Play idle animation
		$Sprite.play(animation)
		
		
		
func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	# 0.707 = sqrt(2)/2 radians or 45 deg
	# up/down have higher priority over left/right
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"
	

# Events that specifically involve the player
func _input_event(viewport, event, shape_idx):
	# Using the mouse to move the player
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			drag_enabled = event.pressed

# Any event that is detected
func _input(event):
	# Mouse button clicked outside of player
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			drag_enabled = false
			
	# Attacking
	if event.is_action_pressed("ui_attack"):
		attack_playing = true
		var animation = get_animation_direction(last_direction) + "_attack"
		$Sprite.play(animation)
	elif event.is_action_pressed("ui_fireball"):
		attack_playing = true
		var animation = get_animation_direction(last_direction) + "_fireball"
		$Sprite.play(animation)


func _on_Sprite_animation_finished():
	attack_playing = false
