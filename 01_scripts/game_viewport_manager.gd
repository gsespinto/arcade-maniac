extends SubViewport
class_name GameViewportManager

signal on_game_changed

@export var games : Array[GameViewport]
@export var ui : TvUi
@export var character_viewport : CharacterViewport

var _current_game : GameViewport
var _is_paused : bool = false

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	assert(not games.is_empty(), "Game Viewport Manager must at least have one GameViewport child!")
	assert(is_instance_valid(ui), "Game Viewport Manager must have a valid TvUi reference!")
	
	for game in games:
		game.set_process_mode(PROCESS_MODE_DISABLED)
		game.on_game_over.connect(_open_ui.bind("GameOver"))
		game.on_won.connect(_won_game.bind(game))
		remove_child(game)
	
	ui.started_game.connect(_close_ui)
	ui.resumed_game.connect(_unpause)
	ui.changed_focus.connect(character_viewport.play_animation.bind("ButtonPress"))


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
	
	_set_current_game((games.find(_current_game) + 1) % games.size())


func _set_current_game(index : int) -> void:
	if index < 0 or index >= games.size():
		print("Invalid index! Couldn't set current game!")
		return
	
	if is_instance_valid(_current_game):
		_current_game.set_process_mode(PROCESS_MODE_DISABLED)
		remove_child(_current_game)
	
	games[index].set_process_mode(PROCESS_MODE_INHERIT)
	add_child(games[index])
	
	_current_game = games[index]
	
	on_game_changed.emit(index)
	character_viewport.play_animation("ButtonPress")


func _open_ui(tab : String) -> void:
	character_viewport.play_animation("ButtonPress")
	_current_game.set_process_mode(PROCESS_MODE_DISABLED)
	ui.open_tab(tab)
	ui.set_process_mode(PROCESS_MODE_INHERIT)
	ui.set_visible(true)


func _close_ui() -> void:
	character_viewport.play_animation("ButtonPress")
	_current_game.set_process_mode(PROCESS_MODE_INHERIT)
	ui.set_process_mode(PROCESS_MODE_DISABLED)
	ui.set_visible(false)


func get_look_at_pos() -> Vector2:
	if ui.visible:
		return ui.get_focus_position()
	
	if is_instance_valid(_current_game):
		return _current_game.look_at_target.position
	
	return Vector2.ZERO


func _pause() -> void:
	_open_ui("PauseMenu")
	_is_paused = true


func _unpause() -> void:
	_close_ui()
	_is_paused = false


func _remove_game(game : GameViewport) -> void:
	game.queue_free()
	games.erase(game)


func _won_game(game : GameViewport) -> void:
	if games.size() > 1:
		_go_to_next_game()
	else:
		_open_ui("Won")
	
	_remove_game(game)
