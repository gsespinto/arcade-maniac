extends SubViewport
class_name GameViewportManager

@export var games : Array[GameViewport]

var _current_game : int = 0
signal on_game_changed

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	assert(not games.is_empty(), "Game Viewport Manager must at least have one GameViewport child!")
	for game in games:
		game.set_process_mode(PROCESS_MODE_DISABLED)
		remove_child(game)


func _ready() -> void:
	_set_current_game(0)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next_game"):
		_go_to_next_game()


func _go_to_next_game() -> void:
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


func get_current_game() -> GameViewport:
	return games[_current_game]
