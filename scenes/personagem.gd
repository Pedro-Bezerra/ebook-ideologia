extends CharacterBody2D

@export var speed = 50.0

var can_move: bool = true

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide() 
		return

	var accelerometer = Input.get_accelerometer()
	var direction = Vector2(accelerometer.x, -accelerometer.y)
	
	if direction.length() < 0.1:
		direction = Vector2.ZERO

	velocity = direction * speed
	move_and_slide()
