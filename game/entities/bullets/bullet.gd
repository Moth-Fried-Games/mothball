extends CharacterBody2D

const SPEED = 300.0

var active: bool = false
var start_position: Vector2 = Vector2.ZERO
var last_position_x : float = 0
var level : int = 0
var speed_modifier: float = 0
var size_modifier: float = 0
var start_velocity: Vector2 = Vector2.ZERO

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	
	if active:
		
		if collision_shape_2d.disabled:
			collision_shape_2d.disabled = false
		
		var collision = move_and_collide(velocity * delta)
	
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			start_velocity = start_velocity.bounce(collision.get_normal())

		last_position_x = global_position.x
		global_position.x = wrapf(global_position.x, 0, 320)
		
		if last_position_x != global_position.x:
			power_up()
			last_position_x = global_position.x
		
		if velocity != start_velocity + (start_velocity * speed_modifier):
			velocity = start_velocity + (start_velocity * speed_modifier)
	
	else:
		global_position = start_position
		if !collision_shape_2d.disabled:
			collision_shape_2d.disabled = true

func _process(delta: float) -> void:
	if scale != Vector2.ONE + (Vector2.ONE * size_modifier):
		scale = Vector2.ONE + (Vector2.ONE * size_modifier)

func power_up():
	match level:
		0:
			level = 1
			speed_modifier = 0.33
			size_modifier = 0.33
			
		1:
			level = 2
			speed_modifier = 0.66
			size_modifier = 0.66
		2:
			level = 3
			speed_modifier = 1
			size_modifier = 1
