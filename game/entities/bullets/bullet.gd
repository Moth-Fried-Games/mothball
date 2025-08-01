extends CharacterBody2D

const MOTHBALL_BALL_1 = preload("res://assets/textures/mothball_ball1.png")
const MOTHBALL_BALL_2 = preload("res://assets/textures/mothball_ball2.png")
const MOTHBALL_BALL_3 = preload("res://assets/textures/mothball_ball3.png")
const MOTHBALL_BALL_4 = preload("res://assets/textures/mothball_ball4.png")

const PARTICLE_1 = preload("res://game/entities/particles/particle_1.tscn")
const PARTICLE_2 = preload("res://game/entities/particles/particle_2.tscn")
const PARTICLE_3 = preload("res://game/entities/particles/particle_3.tscn")
const PARTICLE_4 = preload("res://game/entities/particles/particle_4.tscn")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D

const SPEED = 300.0

var active: bool = false
var start_position: Vector2 = Vector2.ZERO
var last_position_x: float = 0
var level: int = 0
var speed_modifier: float = 0
var ball_radius: float = 4
var start_velocity: Vector2 = Vector2.ZERO
var ball_impact: bool = false
var player_impact: bool = false
var player_number: int = 1


func _ready() -> void:
	add_to_group("ball")
	start_position = global_position


func _physics_process(delta: float) -> void:
	if active:
		if collision_shape_2d.disabled:
			collision_shape_2d.disabled = false
			area_collision_shape_2d.disabled = false

		if not ball_impact:
			if area_2d.has_overlapping_areas():
				ball_impact = true
				var balls := area_2d.get_overlapping_areas()
				var level_total: int = 0
				for ball in balls:
					ball.get_parent().ball_impact = true
					level_total += ball.get_parent().level
					ball.get_parent().process_balls(level)
				process_balls(level_total)

		if not player_impact:
			if area_2d.has_overlapping_bodies():
				player_impact = true
				var bodies := area_2d.get_overlapping_bodies()
				var player_node = null
				for b in bodies:
					if b.is_in_group("player"):
						player_node = b
				if level > 0 and is_instance_valid(player_node):
					if player_node.player == "P1":
						GameGlobals.game_dictionary["game_scene"].player_hit(1, level)
					else:
						GameGlobals.game_dictionary["game_scene"].player_hit(2, level)
					spawn_particle()
					level = 0
					power_down()
				else:
					player_impact = false

		var collision = move_and_collide(velocity * delta)

		if collision:
			velocity = velocity.bounce(collision.get_normal())
			start_velocity = start_velocity.bounce(collision.get_normal())

		last_position_x = global_position.x
		global_position.x = wrapf(global_position.x, 0 - ball_radius, 320 + ball_radius)

		if last_position_x != global_position.x:
			power_up()
			last_position_x = global_position.x

		if velocity != start_velocity + (start_velocity * speed_modifier):
			velocity = start_velocity - (start_velocity * speed_modifier)

	else:
		global_position = start_position
		if !collision_shape_2d.disabled:
			collision_shape_2d.disabled = true
			area_collision_shape_2d.disabled = true


func _process(_delta: float) -> void:
	pass


func process_balls(value: int) -> void:
	spawn_particle()
	for v in range(value):
		if level > 0:
			level -= 1
	power_down()


func power_down():
	match level:
		0:
			active = false
			if player_number == 1:
				GameGlobals.game_dictionary["game_scene"].update_p1_ammo()
			else:
				GameGlobals.game_dictionary["game_scene"].update_p2_ammo()
			level = 0
			speed_modifier = 0
			ball_radius = 4
			collision_shape_2d.shape.radius = ball_radius
			area_collision_shape_2d.shape.radius = ball_radius
			sprite_2d.texture = MOTHBALL_BALL_1
		1:
			level = 0
			speed_modifier = 0
			ball_radius = 4
			collision_shape_2d.shape.radius = ball_radius
			area_collision_shape_2d.shape.radius = ball_radius
			sprite_2d.texture = MOTHBALL_BALL_1
		2:
			level = 1
			speed_modifier = 0.25
			ball_radius = 8
			collision_shape_2d.shape.radius = ball_radius
			area_collision_shape_2d.shape.radius = ball_radius
			sprite_2d.texture = MOTHBALL_BALL_2
		3:
			level = 2
			speed_modifier = 0.50
			ball_radius = 16
			collision_shape_2d.shape.radius = ball_radius
			area_collision_shape_2d.shape.radius = ball_radius
			sprite_2d.texture = MOTHBALL_BALL_3
	await get_tree().create_timer(0.05).timeout
	ball_impact = false
	player_impact = false


func power_up():
	match level:
		0:
			level = 1
			speed_modifier = 0.25
			ball_radius = 8
			collision_shape_2d.shape.radius = ball_radius
			area_collision_shape_2d.shape.radius = ball_radius
			sprite_2d.texture = MOTHBALL_BALL_2
		1:
			level = 2
			speed_modifier = 0.50
			ball_radius = 16
			collision_shape_2d.shape.radius = ball_radius
			area_collision_shape_2d.shape.radius = ball_radius
			sprite_2d.texture = MOTHBALL_BALL_3
		2:
			level = 3
			speed_modifier = 0.75
			ball_radius = 24
			collision_shape_2d.shape.radius = ball_radius
			area_collision_shape_2d.shape.radius = ball_radius
			sprite_2d.texture = MOTHBALL_BALL_4

func spawn_particle():
	var particle_resource = null
	match level:
		0:
			particle_resource = PARTICLE_1.instantiate()
		1:
			particle_resource = PARTICLE_2.instantiate()
		2:
			particle_resource = PARTICLE_3.instantiate()
		3:
			particle_resource = PARTICLE_4.instantiate()
	
	particle_resource.global_position = global_position
	particle_resource.emitting = true
	get_parent().get_parent().add_child(particle_resource)
