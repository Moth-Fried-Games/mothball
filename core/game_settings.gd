@tool
extends Node
class_name GameSettings

@export var display_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
@export var vsync_mode: DisplayServer.VSyncMode = DisplayServer.VSYNC_ENABLED
@export_enum("Uncapped", "30", "60", "Auto") var frame_rate_cap: int = 3
@export var show_fps: bool = false

@export_range(0, 1) var master_volume: float = 0.5
@export_range(0, 1) var music_volume: float = 0.5
@export_range(0, 1) var sound_volume: float = 0.5
@export_range(0, 1) var ui_volume: float = 0.5

@export_range(0.01, 1) var mouse_sensitivity: float = 0.5

@export var stretch_mode: bool = false

var last_viewport_size: Vector2 = Vector2.ZERO


func _process(_delta: float) -> void:
	update_stretch_mode()


func update_stretch_mode() -> void:
	if stretch_mode:
		var current_viewport_size: Vector2 = get_window().size
		if last_viewport_size != current_viewport_size:
			last_viewport_size = current_viewport_size
			if last_viewport_size.x >= 320 and last_viewport_size.y >= 180:
				get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
				get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
				#print("Normal Window")
			else:
				get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
				get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
				#print("Smaller Window")


func load_settings() -> void:
	update_display_mode(display_mode)
	update_vsync_mode(vsync_mode)
	update_frame_rate_cap(frame_rate_cap)
	update_master_volume(master_volume)
	update_music_volume(music_volume)
	update_sound_volume(sound_volume)
	update_ui_volume(ui_volume)


func update_display_mode(new_display_mode: DisplayServer.WindowMode) -> void:
	display_mode = new_display_mode
	DisplayServer.window_set_mode(display_mode)


func update_vsync_mode(new_vsync_mode: DisplayServer.VSyncMode) -> void:
	vsync_mode = new_vsync_mode
	DisplayServer.window_set_vsync_mode(vsync_mode)


func update_frame_rate_cap(new_frame_rate_cap: int) -> void:
	frame_rate_cap = new_frame_rate_cap
	match frame_rate_cap:
		0:
			Engine.set_max_fps(0)
		1:
			Engine.set_max_fps(30)
		2:
			Engine.set_max_fps(60)
		3:
			var display_refresh: float = DisplayServer.screen_get_refresh_rate()
			Engine.set_max_fps(ceili(display_refresh))


func update_show_fps(new_show_fps: bool) -> void:
	show_fps = new_show_fps


func update_master_volume(new_master_volume: float) -> void:
	master_volume = new_master_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))


func update_music_volume(new_music_volume: float) -> void:
	music_volume = new_music_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))


func update_sound_volume(new_sound_volume: float) -> void:
	sound_volume = new_sound_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear_to_db(sound_volume))


func update_ui_volume(new_ui_volume: float) -> void:
	ui_volume = new_ui_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ui"), linear_to_db(ui_volume))


func update_mouse_sensitivity(new_mouse_sensitivity: float) -> void:
	mouse_sensitivity = new_mouse_sensitivity
	mouse_sensitivity = clampf(mouse_sensitivity, 0.01, 1)
