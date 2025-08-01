extends CharacterBody2D

const MOTHBALL_BALL_1 = preload("res://assets/textures/mothball_ball1.png")
const MOTHBALL_BALL_2 = preload("res://assets/textures/mothball_ball2.png")
const MOTHBALL_BALL_3 = preload("res://assets/textures/mothball_ball3.png")
const MOTHBALL_BALL_4 = preload("res://assets/textures/mothball_ball4.png")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

const SPEED = 300.0

var active: bool = false
var start_position: Vector2 = Vector2.ZERO
var last_position_x: float = 0
var level: int = 0
var speed_modifier: float = 0
var ball_radius: float = 4
var start_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	start_position = global_position


func _physics_process(delta: float) -> void:
	if active:
		if collision_shape_2d.disabled:
			collision_shape_2d.disabled = false
			area_collision_shape_2d.disabled = false

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
