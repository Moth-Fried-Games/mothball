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
@onready var animation_player: AnimationPlayer = $Visuals/Messages/AnimationPlayer
@onready var win_label: Label = $Visuals/Messages/Winner/Label

var p1_ammo: int = 5
var p2_ammo: int = 5
var time_remaining: int = 99
var p1_score: int = 5
var p2_score: int = 5
var game_end: bool = false
var game_result: bool = false
var game_pause: bool = true


func _enter_tree() -> void:
	add_to_group("world")


func _input(_event: InputEvent) -> void:
	if Input.is_anything_pressed() and game_result:
		change_to_menu()


func change_to_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	GameGlobals.game_dictionary["game_screen"] = false
	if is_instance_valid(GameGlobals.game_dictionary["music_game"]):
		GameGlobals.audio_manager.fade_audio_out_and_destroy(
			"music_game", GameGlobals.game_dictionary["music_game"], 1
		)
	GameUi.ui_transitions.change_scene(GameGlobals.menu_scene)


func _ready() -> void:
	GameUi.ui_transitions.toggle_transition(false)
	GameGlobals.game_dictionary["game_screen"] = true
	GameGlobals.game_dictionary["game_scene"] = self
	game_timer.timeout.connect(_on_game_timer_timeout)
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	timer_label.text = str("%02d" % [time_remaining])
	score_label_1.text = str(p1_score)
	score_label_2.text = str(p2_score)


func _process(_delta: float) -> void:
	if not game_end:
		if game_pause:
			if player_1.player_ready and player_2.player_ready:
				if not animation_player.is_playing():
					animation_player.play("start")
	else:
		if player_1.player_ready and player_2.player_ready:
			if not animation_player.is_playing() and not game_result:
				game_results()
				animation_player.play("result")


func _physics_process(_delta: float) -> void:
	pass


func _on_game_timer_timeout() -> void:
	if not game_pause:
		if time_remaining > 0:
			time_remaining -= 1
			timer_label.text = str("%02d" % [time_remaining])
			game_timer.start()
		if time_remaining == 0:
			game_over()


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "start":
		game_timer.start()
		game_pause = false
	if anim_name == "result":
		game_result = true


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
	game_pause = true
	game_timer.stop()


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
		win_label.text = "P2\nWINS"
	if p2_score == 0:  # p1 wins
		win_label.text = "P1\nWINS"
	if p1_score == p2_score:  #draw
		win_label.text = "DRAW"
