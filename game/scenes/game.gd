extends Node2D

const MOTHBALL_UI_HUD_BLUE_1 = preload("res://assets/textures/mothball_ui_hud_blue1.png")
const MOTHBALL_UI_HUD_BLUE_2 = preload("res://assets/textures/mothball_ui_hud_blue2.png")
const MOTHBALL_UI_HUD_BLUE_3 = preload("res://assets/textures/mothball_ui_hud_blue3.png")
const MOTHBALL_UI_HUD_BLUE_4 = preload("res://assets/textures/mothball_ui_hud_blue4.png")
const MOTHBALL_UI_HUD_BLUE_5 = preload("res://assets/textures/mothball_ui_hud_blue5.png")
const MOTHBALL_UI_HUD_RED_1 = preload("res://assets/textures/mothball_ui_hud_red1.png")
const MOTHBALL_UI_HUD_RED_2 = preload("res://assets/textures/mothball_ui_hud_red2.png")
const MOTHBALL_UI_HUD_RED_3 = preload("res://assets/textures/mothball_ui_hud_red3.png")
const MOTHBALL_UI_HUD_RED_4 = preload("res://assets/textures/mothball_ui_hud_red4.png")
const MOTHBALL_UI_HUD_RED_5 = preload("res://assets/textures/mothball_ui_hud_red5.png")

@onready var game_timer: Timer = $GameTimer
@onready var timer_label: Label = $Visuals/UISprite2D/TimerLabel
@onready var score_label_1: Label = $Visuals/UISprite2D/ScoreLabel1
@onready var score_label_2: Label = $Visuals/UISprite2D/ScoreLabel2
@onready var p_1_ammo_sprite_2d: Sprite2D = $Visuals/UISprite2D/P1AmmoSprite2D
@onready var p_2_ammo_sprite_2d: Sprite2D = $Visuals/UISprite2D/P2AmmoSprite2D
@onready var player_1: CharacterBody2D = $Entities/Player1
@onready var player_2: CharacterBody2D = $Entities/Player2

var p1_ammo: int = 5
var p2_ammo: int = 5
var time_remaining: int = 99
var p1_score: int = 5
var p2_score: int = 5
var game_end: bool = false


func _enter_tree() -> void:
	add_to_group("world")


func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)
	GameGlobals.game_dictionary["game_scene"] = self
	game_timer.timeout.connect(_on_game_timer_timeout)
	game_timer.start()
	timer_label.text = str("%02d" % [time_remaining])
	score_label_1.text = str(p1_score)
	score_label_2.text = str(p2_score)


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _on_game_timer_timeout() -> void:
	if time_remaining > 0:
		time_remaining -= 1
		timer_label.text = str("%02d" % [time_remaining])
		game_timer.start()
	if time_remaining == 0:
		game_over()


func player_hit(player_number: int, score: int) -> void:
	match player_number:
		1:
			for s in range(score):
				if p1_score > 0:
					p1_score -= 1
					p2_score += 1
			if p1_score == 0:
				game_over()
		2:
			for s in range(score):
				if p2_score > 0:
					p2_score -= 1
					p1_score += 1
			if p2_score == 0:
				game_over()
	score_label_1.text = str(p1_score)
	score_label_2.text = str(p2_score)


func update_p1_ammo() -> void:
	p1_ammo = 0
	for bullet in player_1.bullets:
		if not bullet.active:
			p1_ammo += 1

	match p1_ammo:
		0:
			p_1_ammo_sprite_2d.texture = null
		1:
			p_1_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_BLUE_1
		2:
			p_1_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_BLUE_2
		3:
			p_1_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_BLUE_3
		4:
			p_1_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_BLUE_4
		5:
			p_1_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_BLUE_5


func update_p2_ammo() -> void:
	p2_ammo = 0
	for bullet in player_2.bullets:
		if not bullet.active:
			p2_ammo += 1

	match p2_ammo:
		0:
			p_2_ammo_sprite_2d.texture = null
		1:
			p_2_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_RED_1
		2:
			p_2_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_RED_2
		3:
			p_2_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_RED_3
		4:
			p_2_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_RED_4
		5:
			p_2_ammo_sprite_2d.texture = MOTHBALL_UI_HUD_RED_5


func game_over() -> void:
	if time_remaining == 0:
		game_end = true
	if p1_score == 0 or p2_score == 0:
		game_end = true


func game_results() -> void:
	if p1_score == 0:  # p2 wins
		pass
	if p2_score == 0:  # p1 wins
		pass
	if p1_score == p2_score:  #draw
		pass
