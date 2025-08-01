extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_arrow: Sprite2D = $PlayerArrow

const SPEED: float = 300

@export var max_speed: float = 100
@export var acceleration: float = 500
@export var friction: float = 500
@export var bullets: Array[CharacterBody2D]
@export_enum("P1", "P2", "CPU") var player: String = "P1"

var motion: Vector2 = Vector2.ZERO
var input_vector: Vector2 = Vector2.ZERO
var snapped_input_vector: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var starting_position: Vector2 = Vector2.ZERO

var cpu_shoot: bool = false


func _ready() -> void:
	starting_position = global_position
	match player:
		"P1":
			set_collision_mask_value(5, true)
			set_collision_mask_value(6, false)
		"P2":
			set_collision_mask_value(5, false)
			set_collision_mask_value(6, true)
			animated_sprite_2d.rotation = Vector2.LEFT.angle()
		"CPU":
			set_collision_mask_value(5, false)
			set_collision_mask_value(6, true)
			animated_sprite_2d.rotation = Vector2.LEFT.angle()


func _process(delta: float) -> void:
	if input_vector != Vector2.ZERO:
		if animated_sprite_2d.animation != "move":
			animated_sprite_2d.play("move")
		animated_sprite_2d.rotation = snapped_input_vector.angle()
		player_arrow.rotation = animated_sprite_2d.rotation
		player_arrow.show()
	else:
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")
		player_arrow.hide()


func _physics_process(delta: float) -> void:
	movement(delta)
	shoot()


func movement(delta) -> void:
	input_vector = Vector2.ZERO

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
	var angle = rad_to_deg(input_vector.angle())
	angle = snappedf(angle, 45.0)
	snapped_input_vector = Vector2.from_angle(deg_to_rad(angle))
	
	if input_vector != Vector2.ZERO:
		motion = motion.move_toward(snapped_input_vector * max_speed, acceleration * delta)
		last_direction = snapped_input_vector
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
		"CPU":
			player_shoot = cpu_shoot

	if player_shoot:
		for bullet in bullets:
			if !bullet.active:
				bullet.global_position = global_position
				bullet.velocity = Vector2(bullet.SPEED, 0).rotated(last_direction.angle())
				bullet.start_velocity = bullet.velocity
				bullet.active = true
				if player == "P1":
					GameGlobals.game_dictionary["game_scene"].update_p1_ammo()
				else:
					GameGlobals.game_dictionary["game_scene"].update_p2_ammo()
				break
