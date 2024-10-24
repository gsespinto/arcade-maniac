extends Node2D
class_name GameViewport

@export var look_at_target : Node2D

signal on_game_over
signal on_won

var has_won : bool = false


func win() -> void:
	has_won = true
	on_won.emit()
	set_process_mode(Node.PROCESS_MODE_DISABLED)


func lose() -> void:
	on_game_over.emit()
	set_process_mode(Node.PROCESS_MODE_DISABLED)
