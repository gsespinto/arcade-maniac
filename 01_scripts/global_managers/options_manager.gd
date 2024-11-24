extends Node

const MAX_MUSIC_VOLUME : float = 10.0
const MIN_MUSIC_VOLUME : float = -50.0

const MAX_GAME_VOLUME : float = 10.0
const MIN_GAME_VOLUME : float = -25.0

const LOCALES : PackedStringArray = ["en", "pt", "es", "de"]
const LOCALE_NAMES : PackedStringArray = ["English", "Português", "Español", "Deutsch"]

var is_fullscreen : bool = true

var game_volume : float = 0.0
var music_volume : float = -10.0

var music_files : PackedStringArray = []

var current_locale : int = 0


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if not DataManager.has_loaded_data:
		await DataManager.loaded_data
	
	set_fullscreen(DataManager.get_data("Options", "is_fullscreen", true))
	set_game_volume(DataManager.get_data("Options", "game_volume", 0.0))
	set_music_volume(DataManager.get_data("Options", "music_volume", -10.0))
	set_music_files(DataManager.get_data("Options", "music_files", []))
	set_current_locale(DataManager.get_data("Options", "current_locale", 0))


func toggle_fullscreen():
	set_fullscreen(not is_fullscreen)


func set_fullscreen(fullscreen : bool):
	is_fullscreen = fullscreen
	DataManager.set_data("Options", "is_fullscreen", is_fullscreen)
	
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func set_game_volume(volume_db : float):
	game_volume = clampf(volume_db, MIN_GAME_VOLUME, MAX_GAME_VOLUME)
	if is_equal_approx(game_volume, MIN_GAME_VOLUME):
		game_volume = -80.0
	
	DataManager.set_data("Options", "game_volume", game_volume)
	AudioServer.set_bus_volume_db(0, game_volume)


func set_music_volume(volume_db : float):
	music_volume = clampf(volume_db, MIN_MUSIC_VOLUME, MAX_MUSIC_VOLUME)
	if is_equal_approx(music_volume, MIN_MUSIC_VOLUME):
		music_volume = -80.0

	DataManager.set_data("Options", "music_volume", music_volume)
	for node in get_tree().get_nodes_in_group("music"):
		if node.has_method("set_volume_db"):
			node.set_volume_db(music_volume)


func set_music_files(files : PackedStringArray):
	music_files = files
	DataManager.set_data("Options", "music_files", music_files)


func cycle_locales():
	var next_locale : int = (current_locale + 1) % LOCALES.size()
	set_current_locale(next_locale)


func set_current_locale(locale_index : int):
	current_locale = clampi(locale_index, 0, LOCALES.size() - 1)
	
	DataManager.set_data("Options", "current_locale", current_locale)
	TranslationServer.set_locale(LOCALES[locale_index])


func get_current_locale_name() -> String:
	return LOCALE_NAMES[current_locale]
