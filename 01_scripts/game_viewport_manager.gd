extends SubViewport
class_name GameViewportManager

signal on_game_changed
signal on_game_removed

@export var games : Array[GameViewport]
@export var ui : TvUi
@export var character_viewport : CharacterViewport

@export var change_game_time_range : Vector2 = Vector2(5, 10)
var _change_game_timer : Timer = null

@export var sequential : bool = true

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
	
	ui.started_game.connect(_start_game)
	ui.resumed_game.connect(_unpause)
	ui.changed_focus.connect(character_viewport.play_animation.bind("ButtonPress"))


func _ready() -> void:
	_change_game_timer = Timer.new()
	_change_game_timer.timeout.connect(_go_to_next_game)
	
	add_child(_change_game_timer)
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


func _start_game() -> void:
	_close_ui()
	_change_game_timer.start(randf_range(change_game_time_range.x, change_game_time_range.y))


func _go_to_next_game() -> void:
	if ui.visible or games.size() <= 1:
		return
	
	if sequential:
		_set_current_game((games.find(_current_game) + 1) % games.size())
	else:
		_set_current_game(randi_range(0, games.size() - 1))
	_change_game_timer.start(randf_range(change_game_time_range.x, change_game_time_range.y))


func _set_current_game(index : int) -> void:
	if index < 0 or index >= games.size():
		print("Invalid index! Couldn't set current game!")
		return
	
	if index == games.find(_current_game):
		return
	
	if is_instance_valid(_current_game):
		_current_game.set_process_mode(PROCESS_MODE_DISABLED)
		remove_child(_current_game)
	
	var is_first_game : bool = _current_game == null
	add_child(games[index])
	_current_game = games[index]
	on_game_changed.emit(index)
	character_viewport.play_animation("ButtonPress")
	
	if not is_first_game:
		await get_tree().create_timer(1.0).timeout
		games[index].set_process_mode(PROCESS_MODE_INHERIT)
	
	character_viewport.play_animation("ButtonPress")


func _open_ui(tab : String) -> void:
	_change_game_timer.set_paused(true)
	
	character_viewport.play_animation("ButtonPress")
	_current_game.set_process_mode(PROCESS_MODE_DISABLED)
	ui.open_tab(tab)
	ui.set_process_mode(PROCESS_MODE_INHERIT)
	ui.set_visible(true)


func _close_ui() -> void:
	_change_game_timer.set_paused(false)
	if _change_game_timer.time_left > 0:
		_change_game_timer.start(_change_game_timer.time_left)
	
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
	on_game_removed.emit(games.find(game))
	game.queue_free()
	games.erase(game)


func _won_game(game : GameViewport) -> void:
	game.set_process_mode(PROCESS_MODE_DISABLED)
	_change_game_timer.set_paused(true)
	await get_tree().create_timer(2.0).timeout
	_change_game_timer.set_paused(false)

	if games.size() > 1:
		_go_to_next_game()
	else:
		_open_ui("Won")
	
	_remove_game(game)
