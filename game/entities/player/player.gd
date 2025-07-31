extends CharacterBody2D

const SPEED = 300.0

@export var max_speed = 80
@export var acceleration = 500
@export var friction = 500

var motion = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	movement(delta)

func movement(delta) -> void:
	var input_vector = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		motion = motion.move_toward(input_vector * max_speed, acceleration * delta)
	else:		
		motion = motion.move_toward(Vector2.ZERO, friction * delta)
	
	velocity = motion
	move_and_slide()
	motion = velocity
