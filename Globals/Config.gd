extends Node

const SAVE_PATH := "user://data_config.save"
const GAME_VERSION := "1.0.0"

enum SCREEN_MODES {
	FULLSCREEN, BORDERLESS, WINDOWED
}

enum AA_MODES {
	DISABLED, FXAA, MSAA2X, MSAA4X,
	MSAA8X, MSAA16X
}

var music_volume := 0.7 setget set_music_volume
var sound_volume := 1.0 setget set_sound_volume
var resolution := Vector2(1920, 1080) setget set_resolution
var point_multiplier := 1.0 setget set_point_multiplier
var screen_shake := 1.0 setget set_screen_shake
var screen_mode : int = SCREEN_MODES.FULLSCREEN setget set_screen_mode
var aa_mode : int = AA_MODES.MSAA4X setget set_aa_mode
var vsync := true setget set_vsync
var bloom := true setget set_bloom
var show_bar := true setget set_show_bar
var show_percentage := false setget set_show_percentage
var always_show_hud := false setget set_always_show_hud
var show_fps := false setget set_show_fps
var player_ring := true setget set_player_ring
var infinite_hp := false setget set_infinite_hp
var infinite_jump := false setget set_infinite_jump
var infinite_items := false setget set_infinite_items

signal bloom_changed(is_active)
signal show_fps_changed(is_active)


func save_data() -> void:
	var save_dict := {}
	save_dict["music_volume"] = music_volume
	save_dict["sound_volume"] = sound_volume
	save_dict["point_multiplier"] = point_multiplier
	save_dict["screen_shake"] = screen_shake
	save_dict["resolution"] = resolution
	save_dict["screen_mode"] = screen_mode
	save_dict["aa_mode"] = aa_mode
	save_dict["vsync"] = vsync
	save_dict["bloom"] = bloom
	save_dict["show_bar"] = show_bar
	save_dict["show_percentage"] = show_percentage
	save_dict["always_show_hud"] = always_show_hud
	save_dict["show_fps"] = show_fps
	save_dict["player_ring"] = player_ring
	save_dict["infinite_hp"] = infinite_hp
	save_dict["infinite_jump"] = infinite_jump
	save_dict["infinite_items"] = infinite_items
	save_dict["keyboard_controls"] = get_keyboard_dict()
	save_dict["gamepad_controls"] = get_gamepad_dict()
	var file := File.new()
	file.open(SAVE_PATH, File.WRITE)
	file.store_var(save_dict)
	file.close()


func load_data() -> void:
	var file := File.new()
	if file.file_exists(SAVE_PATH):
		file.open(SAVE_PATH, File.READ)
		var values : Dictionary = file.get_var()
		
		self.music_volume = values.get("music_volume", 0.7)
		self.sound_volume = values.get("sound_volume", 1.0)
		self.screen_shake = values.get("screen_shake", 1.0)
		self.point_multiplier = values.get("point_multiplier", 1.0)
		self.resolution = values.get("resolution", Vector2(1920, 1080))
		self.screen_mode = values.get("screen_mode", SCREEN_MODES.FULLSCREEN)
		self.aa_mode = values.get("aa_mode", AA_MODES.MSAA4X)
		self.vsync = values.get("vsync", true)
		self.bloom = values.get("bloom", true)
		self.show_bar = values.get("show_bar", true)
		self.show_percentage = values.get("show_percentage", false)
		self.always_show_hud = values.get("always_show_hud", false)
		self.show_fps = values.get("show_fps", false)
		self.player_ring = values.get("player_ring", true)
		self.infinite_hp = values.get("infinite_hp", false)
		self.infinite_jump = values.get("infinite_jump", false)
		self.infinite_items = values.get("infinite_items", false)
		
		var keyboard_controls : Dictionary = values.get("keyboard_controls", {})
		for action in keyboard_controls:
			InputHelper.set_action_key(action, keyboard_controls[action])
		
		var gamepad_controls : Dictionary = values.get("gamepad_controls", {})
		for action in gamepad_controls:
			InputHelper.set_action_button(action, gamepad_controls[action])
		
		file.close()
	else:
		save_data()


func set_music_volume(value: float) -> void:
	music_volume = value
	SoundManager.set_music_volume(value)


func set_sound_volume(value: float) -> void:
	sound_volume = value
	SoundManager.set_sound_volume(value)


func set_screen_shake(value: float) -> void:
	screen_shake = value


func set_point_multiplier(value: float) -> void:
	point_multiplier = value


func set_bloom(value: bool) -> void:
	bloom = value
	emit_signal("bloom_changed", value)


func set_show_bar(value: bool) -> void:
	show_bar = value


func set_show_percentage(value: bool) -> void:
	show_percentage = value


func set_show_fps(value: bool) -> void:
	show_fps = value
	emit_signal("show_fps_changed", value)


func set_always_show_hud(value: bool) -> void:
	always_show_hud = value


func set_player_ring(value: bool) -> void:
	player_ring = value


func set_infinite_hp(value: bool) -> void:
	infinite_hp = value


func set_infinite_jump(value: bool) -> void:
	infinite_jump = value


func set_infinite_items(value: bool) -> void:
	infinite_items = value


func set_resolution(value: Vector2) -> void:
	resolution = value
	OS.window_size = value



func set_aa_mode(mode: int) -> void:
	aa_mode = mode
	var viewport := get_tree().get_root()
	viewport.fxaa = false
	viewport.msaa = Viewport.MSAA_DISABLED
	match mode:
		AA_MODES.FXAA:
			viewport.fxaa = true
		AA_MODES.MSAA2X:
			viewport.msaa = Viewport.MSAA_2X
		AA_MODES.MSAA4X:
			viewport.msaa = Viewport.MSAA_4X
		AA_MODES.MSAA8X:
			viewport.msaa = Viewport.MSAA_8X
		AA_MODES.MSAA16X:
			viewport.msaa = Viewport.MSAA_16X
	


func set_screen_mode(mode: int) -> void:
	screen_mode = mode
	match mode:
		SCREEN_MODES.FULLSCREEN:
			OS.window_fullscreen = true
			OS.window_borderless = false
		SCREEN_MODES.BORDERLESS:
			OS.window_fullscreen = false
			OS.window_borderless = true
			OS.window_maximized = true
		SCREEN_MODES.WINDOWED:
			OS.window_fullscreen = false
			OS.window_borderless = false
			OS.window_maximized = false
			OS.window_size = resolution
			# Center window
			var screen_size = OS.get_screen_size()
			var window_size = OS.get_window_size()
			OS.set_window_position(screen_size*0.5 - window_size*0.5)


func set_vsync(value: bool) -> void:
	vsync = value
	OS.vsync_enabled = value


func get_configurable_actions() -> Array:
	return [
		"jump", "left", "right", "forward", "backward", "quick restart",
		"escape", "item 1", "item 2", "item 3", "item 4",
	]


func get_keyboard_dict() -> Dictionary:
	var dict := {}
	for action in get_configurable_actions():
		dict[action] = InputHelper.get_action_key(action)
	return dict


func get_gamepad_dict() -> Dictionary:
	var dict := {}
	for action in get_configurable_actions():
		dict[action] = InputHelper.get_action_button(action)
	return dict