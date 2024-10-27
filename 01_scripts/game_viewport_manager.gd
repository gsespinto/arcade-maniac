extends SubViewport
class_name GameViewportManager

signal on_game_changed

@export var games : Array[GameViewport]
@export var ui : TvUi

var _current_game : int = 0
var _is_paused : bool = false

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	assert(not games.is_empty(), "Game Viewport Manager must at least have one GameViewport child!")
	assert(is_instance_valid(ui), "Game Viewport Manager must have a valid TvUi reference!")
	
	for game in games:
		game.set_process_mode(PROCESS_MODE_DISABLED)
		remove_child(game)
	
	ui.started_game.connect(_close_ui)
	ui.resumed_game.connect(_unpause)


func _ready() -> void:
	_set_current_game(0)
	_open_ui("MainMenu")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next_game"):
		_go_to_next_game()
	
	if Input.is_action_just_pressed("pause"):
		if not ui.visible or ui.get_current_tab() == "PauseMenu":
			if not _is_paused:
				_pause()
			else:
				_unpause()


func _go_to_next_game() -> void:
	if ui.visible:
		return
	
	_set_current_game((_current_game + 1) % games.size())


func _set_current_game(index : int) -> void:
	if index < 0 or index >= games.size():
		print("Invalid index! Couldn't set current game!")
		return
	
	games[_current_game].set_process_mode(PROCESS_MODE_DISABLED)
	remove_child(games[_current_game])
	
	games[index].set_process_mode(PROCESS_MODE_INHERIT)
	add_child(games[index])
	
	_current_game = index
	on_game_changed.emit(index)


func _open_ui(tab : String) -> void:
	games[_current_game].set_process_mode(PROCESS_MODE_DISABLED)
	ui.open_tab(tab)
	ui.set_process_mode(PROCESS_MODE_INHERIT)
	ui.set_visible(true)


func _close_ui() -> void:
	games[_current_game].set_process_mode(PROCESS_MODE_INHERIT)
	ui.set_process_mode(PROCESS_MODE_DISABLED)
	ui.set_visible(false)


func get_look_at_pos() -> Vector2:
	if ui.visible:
		return ui.get_focus_position()
	
	return games[_current_game].look_at_target.position


func _pause() -> void:
	_open_ui("PauseMenu")
	_is_paused = true


func _unpause() -> void:
	_close_ui()
	_is_paused = false
