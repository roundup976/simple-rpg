extends KinematicBody2D


# Node reference
var player

# Random number generator
var rng = RandomNumberGenerator.new()

# Movement variables
export var speed = 25
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0

# Animation variables
var other_animation_playing = false


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().root.get_node("Root/Player")
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	var movement = direction * speed * delta
	var collision = move_and_collide(movement)
	
	if collision != null and collision.collider.name != "Player":
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		bounce_countdown = rng.randi_range(2, 5)
		
	if not other_animation_playing:
		animates_monster(direction)


func _on_Timer_timeout():
	# Calculate the position of the player relative to the skeleton
	var player_relative_position = player.position - position
	
	if player_relative_position.length() <= 16:
		# If player is near, don't move but turn toward it
		direction = Vector2.ZERO
		last_direction = player_relative_position.normalized()
	elif player_relative_position.length() <=100 and bounce_countdown == 0:
		# If player is within range move toward it
		direction = player_relative_position.normalized()
	elif bounce_countdown == 0:
		# If player is to far away randomly decide wether to move or stand still
		var rand_num = rng.randf()
		if rand_num < 0.05:
			direction = Vector2.ZERO
		elif rand_num < 0.1:
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
			
	# Update bounce_countdown
	if bounce_countdown > 0:
		bounce_countdown = bounce_countdown - 1


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
	
	
func animates_monster(direction: Vector2):
	if direction != Vector2.ZERO:
		# update last_direction gradually to eliminate stick bounce
		last_direction = 0.5 * last_direction + 0.5 * direction
		# Choose walk animation based on direction of movement
		var animation = get_animation_direction(last_direction) + "_walk"
		# Set animation frame rate for controller joystick use
		$AnimatedSprite.frames.set_animation_speed(animation, 2+8*direction.length())
		# Play the walk animation
		$AnimatedSprite.play(animation)
	else:
		# Choose the idle animation based on last movement direction
		var animation = get_animation_direction(last_direction) + "_idle"
		# Play idle animation
		$AnimatedSprite.play(animation)
