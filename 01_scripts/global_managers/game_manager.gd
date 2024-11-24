extends Node

signal started
signal restarted
signal won
signal lost

signal paused
signal unpaused

signal started_timer
signal stopped_timer

# Current play time in seconds
var current_time : float = 0.0

# Flags whether the pause menu is opened at the moment
# so that the player can toggle this state with the pause input
var _is_paused : bool = false

var _tick_play_time : bool = false :
	set(value):
		if _tick_play_time == value:
			return
		
		_tick_play_time = value
		if value:
			started_timer.emit()
		else:
			stopped_timer.emit()


func _ready() -> void:
	# Whenever we load a new scene, reset the manager
	# so that the game state and play info is back to original state
	LoadingScreen.loaded.connect(reset)
	set_tree_paused(false)


func _process(delta: float) -> void:
	# Tick current play time
	if _tick_play_time:
		current_time += delta
	
	# On pause input and ui is either hidden 
	# or in pause menu toggle pause state
	if Input.is_action_just_pressed("pause"):
		var tv_ui : TvUi = TvUi.instance
		if not tv_ui.visible or tv_ui.get_current_tab() == "PauseMenu":
			if _is_paused:
				unpause()
			else:
				pause()


func start():
	_tick_play_time = true
	started.emit()


func restart():
	reset()
	TvUi.instance.open_tab("MainMenu")
	restarted.emit()


func win():
	_tick_play_time = false
	won.emit()


func game_over():
	_tick_play_time = false
	lost.emit()


func reset():
	_tick_play_time = false
	_is_paused = false
	current_time = 0


func pause():
	if _is_paused:
		return
	
	_tick_play_time = false
	_is_paused = true
	paused.emit()


func unpause():
	if not _is_paused:
		return
	
	_tick_play_time = true
	_is_paused = false
	unpaused.emit()


func set_tree_paused(paused : bool):
	get_tree().set_pause(paused)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_HIDDEN)


func get_current_time_string() -> String:
	return Utils.get_time_string(current_time)
