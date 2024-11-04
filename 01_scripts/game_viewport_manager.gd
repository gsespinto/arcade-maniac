extends SubViewport
class_name GameViewportManager

## Emitted whenever the current game changes with the new index
signal on_game_changed

## Emitted whenever a game is removed with its index
signal on_game_removed

## Emitted whenever the game ends, either by winning or game over
signal on_end

## Emitted whenever there should be audiovisual interaction feedback in the game
signal on_interaction_feedback


## Array of games that need to be completed to beat the game
@export var games : Array[GameViewport]

## Parent of TV tabs, when this node is visible
## the current game viewport is paused
@export var ui : TvUi

## Should the game switch between the games in the array order or
## pick the next game randomly?
@export var switch_sequentially : bool = true

@export_category("Delays")
## Time range to switch between the current available games
## (x: min, y: max)
@export var change_game_time_range : Vector2 = Vector2(5, 10)
@export var warm_up_delay : float = 1.0
@export var win_delay : float = 1.0

var _change_game_timer : Timer = null
var _current_game : GameViewport
var _is_paused : bool = false


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	assert(not games.is_empty(), "Game Viewport Manager must at least have one GameViewport child!")
	assert(is_instance_valid(ui), "Game Viewport Manager must have a valid TvUi reference!")
	
	for game in games:
		game.set_process_mode(PROCESS_MODE_DISABLED)
		game.on_game_over.connect(_game_over)
		game.on_won.connect(_won_game.bind(game))
		remove_child(game)
	
	ui.started_game.connect(_start_game)
	ui.resumed_game.connect(_unpause)
	ui.changed_focus.connect(on_interaction_feedback.emit)


func _ready() -> void:
	_change_game_timer = Timer.new()
	_change_game_timer.timeout.connect(_go_to_next_game)
	
	add_child(_change_game_timer)
	_set_current_game(0)
	_open_ui("MainMenu")


func _process(delta: float) -> void:
	# Debug input to switch between games
	if not OS.has_feature("standalone") and Input.is_action_just_pressed("next_game"):
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


# Change to next available game, either it be sequentially or randomly.
# If exclude_current, it'll ensure that the current game isn't picked randomly.
func _go_to_next_game(exclude_current : bool = false) -> void:
	if ui.visible or games.size() <= 1:
		return
	
	if switch_sequentially:
		_set_current_game((games.find(_current_game) + 1) % games.size())
	else:
		var available_games : Array = games.duplicate()
		if exclude_current:
			available_games.erase(_current_game)
		_set_current_game(available_games.pick_random())
	
	# Reset change timer
	_change_game_timer.start(randf_range(change_game_time_range.x, change_game_time_range.y))

# Pauses and removes previous game from tree, and sets game at given index
# as current by unpausing it and adding it as child of this subviewport.
# When switching between games, there's a delay before the new game is unpaused.
func _set_current_game(index : int) -> void:
	# Ensure the given game index is valid
	if index < 0 or index >= games.size():
		print("Invalid index! Couldn't set current game!")
		return
	
	# If the given game index is already the current
	# we don't have to do anything
	if index == games.find(_current_game):
		return
	
	# Pause previous game and remove it from the scene tree
	# This is so that physics bodies from this game don't interact
	# with ones of the current game
	if is_instance_valid(_current_game):
		_current_game.set_process_mode(PROCESS_MODE_DISABLED)
		remove_child(_current_game)
	
	var is_first_game : bool = _current_game == null
	
	# Set current game
	add_child(games[index])
	_current_game = games[index]
	on_game_changed.emit(index)
	
	# Set character animation
	on_interaction_feedback.emit()
	
	# If we're switching between two games, they set
	# a delay to give the player some warm up
	if not is_first_game:
		_open_ui("WarmUp")
		
		await get_tree().create_timer(warm_up_delay).timeout
		
		_close_ui()
		on_interaction_feedback.emit()
	
	_current_game.set_process_mode(PROCESS_MODE_INHERIT)


# Requests tv ui to open target tab,
# when successful pauses the game
func _open_ui(tab : String) -> void:
	# If we couldn't open target tab
	# then do nothing
	if not ui.open_tab(tab):
		return
	
	# Pause current game
	_current_game.set_process_mode(PROCESS_MODE_DISABLED)
	_change_game_timer.set_paused(true)
	
	# Show ui
	ui.set_process_mode(PROCESS_MODE_INHERIT)
	ui.set_visible(true)

	on_interaction_feedback.emit()


# If opened, closes tv ui and unpauses the current game
func _close_ui() -> void:
	# Do nothing if the tv ui isn't openned
	if not ui.visible:
		return
	
	# Unpause change game timer
	_change_game_timer.set_paused(false)
	if _change_game_timer.time_left > 0:
		_change_game_timer.start(_change_game_timer.time_left)
	
	# Pause and hide ui
	ui.set_process_mode(PROCESS_MODE_DISABLED)
	ui.set_visible(false)
	
	# Unpause current game
	_current_game.set_process_mode(PROCESS_MODE_INHERIT)
	
	on_interaction_feedback.emit()


# Returns target look position in the tv local position
func get_look_at_pos() -> Vector2:
	# When ui is visible, get the current focus position
	if ui.visible:
		return ui.get_focus_position()
	
	# If there's a valid current game
	# get the look at taget position
	if is_instance_valid(_current_game):
		return _current_game.look_at_target.position
	
	# Return center screen
	return size / 2.0


func _pause() -> void:
	_open_ui("PauseMenu")
	_is_paused = true


func _unpause() -> void:
	_close_ui()
	_is_paused = false


# Frees given game with given name
func _remove_game(game : GameViewport) -> void:
	on_game_removed.emit(games.find(game))
	game.queue_free()
	games.erase(game)


# Called whenever a game is won, if all games have been won
# triggers the win ending, otherwise changes to next game
# and removes current game so it isn't picked further on
func _won_game(game : GameViewport) -> void:
	game.set_process_mode(PROCESS_MODE_DISABLED)
	_change_game_timer.set_paused(true)
	
	await get_tree().create_timer(win_delay).timeout
	_change_game_timer.set_paused(false)
	
	# If there are still games to be won
	# go to next game
	if games.size() > 1:
		_go_to_next_game(true)
	# If all games have been won
	# trigger win ending
	else:
		_open_ui("Won")
		on_end.emit()
	
	# Remove this game so it isn't playble anymore
	_remove_game(game)


# Called whenever any game is lost,
# triggers game over ending
func _game_over() -> void:
	_open_ui("GameOver")
	on_end.emit()
