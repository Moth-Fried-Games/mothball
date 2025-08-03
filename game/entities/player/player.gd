extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_arrow: Sprite2D = $PlayerArrow

const SPEED: float = 150

@export var max_speed: float = 100
@export var acceleration: float = 500
@export var friction: float = 500
@export var bullets: Array[CharacterBody2D]
@export var cpu_shoot_cooldown: float = 2
@export var cpu_ball_danger_distance: float = 100
@export_enum("P1", "P2", "CPU") var player: String = "P1"

var motion: Vector2 = Vector2.ZERO
var input_vector: Vector2 = Vector2.ZERO
var snapped_input_vector: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var starting_position: Vector2 = Vector2.ZERO
var cooldown_timer: float

var player_ready: bool = false


func _ready() -> void:
	add_to_group("player")
	cooldown_timer = randf_range(0.5, cpu_shoot_cooldown)
	starting_position = global_position
	match player:
		"P1":
			set_collision_mask_value(5, true)
			set_collision_mask_value(6, false)
			for ball in bullets:
				ball.player_number = 1
			animated_sprite_2d.rotation = Vector2.RIGHT.angle()
		"P2":
			set_collision_mask_value(5, false)
			set_collision_mask_value(6, true)
			animated_sprite_2d.rotation = Vector2.LEFT.angle()
			for ball in bullets:
				ball.player_number = 2
		"CPU":
			set_collision_mask_value(5, false)
			set_collision_mask_value(6, true)
			animated_sprite_2d.rotation = Vector2.LEFT.angle()
			for ball in bullets:
				ball.player_number = 2


func _process(_delta: float) -> void:
	is_player_ready()
	if input_vector != Vector2.ZERO:
		if animated_sprite_2d.animation != "move":
			animated_sprite_2d.play("move")
		animated_sprite_2d.rotation = snapped_input_vector.angle()
		player_arrow.rotation = animated_sprite_2d.rotation
		if not GameGlobals.game_dictionary["game_scene"].game_pause:
			player_arrow.show()
		else:
			player_arrow.hide()
	else:
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")
		player_arrow.hide()


func _physics_process(delta: float) -> void:
	movement(delta)
	shoot(delta)


func movement(_delta) -> void:
	input_vector = Vector2.ZERO

	if not GameGlobals.game_dictionary["game_scene"].game_pause:
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
			"CPU":
				input_vector = cpu_direction()
	else:
		if global_position != starting_position:
			input_vector = global_position.direction_to(starting_position)
		if global_position.distance_to(starting_position) <= 2:
			global_position = starting_position
			input_vector = Vector2.ZERO
			if player == "P1":
				last_direction = Vector2.RIGHT
			else:
				last_direction = Vector2.LEFT
			animated_sprite_2d.rotation = last_direction.angle()

	input_vector = input_vector.normalized()
	var angle = rad_to_deg(input_vector.angle())
	angle = snappedf(angle, 45.0)
	snapped_input_vector = Vector2.from_angle(deg_to_rad(angle))

	if input_vector != Vector2.ZERO:
		#motion = motion.move_toward(snapped_input_vector * max_speed, acceleration * delta)
		if GameGlobals.game_dictionary["game_scene"].game_pause:
			motion = input_vector * max_speed
		else:
			motion = snapped_input_vector * max_speed
		last_direction = snapped_input_vector
	else:
		#motion = motion.move_toward(Vector2.ZERO, friction * delta)
		motion = Vector2.ZERO

	velocity = motion
	move_and_slide()
	motion = velocity


func shoot(delta):
	var player_shoot = false

	if not GameGlobals.game_dictionary["game_scene"].game_pause:
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
				player_shoot = cpu_shoot(delta)

	if player_shoot:
		for bullet in bullets:
			if !bullet.active:
				bullet.global_position = global_position
				bullet.velocity = Vector2(bullet.SPEED, 0).rotated(last_direction.angle())
				bullet.start_velocity = bullet.velocity
				bullet.active = true
				GameGlobals.audio_manager.create_2d_audio_at_location(
					"sound_ball_throw", global_position
				)
				if player == "P1":
					GameGlobals.game_dictionary["game_scene"].update_p1_ammo()
				else:
					GameGlobals.game_dictionary["game_scene"].update_p2_ammo()
				break


func is_player_ready() -> void:
	if GameGlobals.game_dictionary["game_scene"].game_pause:
		if global_position == starting_position:
			if player == "P1":
				if animated_sprite_2d.rotation == Vector2.RIGHT.angle():
					player_ready = true
				else:
					player_ready = false
			else:
				if animated_sprite_2d.rotation == Vector2.LEFT.angle():
					player_ready = true
				else:
					player_ready = false
		else:
			player_ready = false
	else:
		player_ready = false


func cpu_direction():
	var danger_dir = Vector2.ZERO

	for bullet in get_tree().get_nodes_in_group("ball"):
		var relative_pos = bullet.global_position - global_position

		if relative_pos.length() < cpu_ball_danger_distance and bullet.active:
			danger_dir += bullet.velocity.rotated(PI / 2)

	return danger_dir


func cpu_shoot(delta):
	cooldown_timer -= delta
	if cooldown_timer <= 0:
		cooldown_timer = randf_range(0.5, cpu_shoot_cooldown)
		return true
	return false
