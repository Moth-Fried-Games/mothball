extends CharacterBody2D

const SPEED = 300.0

@export var max_speed = 80
@export var acceleration = 500
@export var friction = 500
@export var bullets: Array[CharacterBody2D]
@export_enum("P1", "P2", "CPU") var player = "P1"

var motion = Vector2.ZERO
var last_direction = Vector2.ZERO


func _ready() -> void:
	match player:
		"P1":
			set_collision_mask_value(5, true)
			set_collision_mask_value(6, false)
		"P2":
			set_collision_mask_value(5, false)
			set_collision_mask_value(6, true)
		"CPU":
			set_collision_mask_value(5, false)
			set_collision_mask_value(6, true)


func _physics_process(delta: float) -> void:
	movement(delta)
	shoot()


func movement(delta) -> void:
	var input_vector = Vector2.ZERO

	match player:
		"P1":
			input_vector = Input.get_vector(
				"move_left_kb1", "move_right_kb1", "move_up_kb1", "move_down_kb1"
			)
			if input_vector == Vector2.ZERO:
				input_vector = Input.get_vector(
					"move_left_joy1", "move_right_joy1", "move_up_joy1", "move_down_joy1"
				)
		"P2":
			input_vector = Input.get_vector(
				"move_left_kb2", "move_right_kb2", "move_up_kb2", "move_down_kb2"
			)
			if input_vector == Vector2.ZERO:
				input_vector = Input.get_vector(
					"move_left_joy2", "move_right_joy2", "move_up_joy2", "move_down_joy2"
				)

	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		motion = motion.move_toward(input_vector * max_speed, acceleration * delta)
		last_direction = input_vector
	else:
		motion = motion.move_toward(Vector2.ZERO, friction * delta)

	velocity = motion
	move_and_slide()
	motion = velocity


func shoot():
	var player_shoot = false

	match player:
		"P1":
			player_shoot = Input.is_action_just_pressed("action_shoot_kb1")
			if !player_shoot:
				player_shoot = Input.is_action_just_pressed("action_shoot_joy1")
		"P2":
			player_shoot = Input.is_action_just_pressed("action_shoot_kb2")
			if !player_shoot:
				player_shoot = Input.is_action_just_pressed("action_shoot_joy2")

	if player_shoot:
		for bullet in bullets:
			if !bullet.active:
				bullet.global_position = global_position
				bullet.velocity = Vector2(bullet.SPEED, 0).rotated(last_direction.angle())
				bullet.start_velocity = bullet.velocity
				bullet.active = true
				break
