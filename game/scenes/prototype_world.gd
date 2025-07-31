extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var color_rect: ColorRect = $ColorRect


func _enter_tree() -> void:
	add_to_group("world")


func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)


func _physics_process(_delta: float) -> void:
	if camera_2d.global_position != (color_rect.size / 2):
		camera_2d.global_position = (color_rect.size / 2)
