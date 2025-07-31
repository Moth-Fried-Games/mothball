extends Node2D


func _enter_tree() -> void:
	add_to_group("world")


func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)


func _physics_process(_delta: float) -> void:
	pass
