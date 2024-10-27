extends Control
class_name TvUi

signal started_game
signal resumed_game

@export var tabs : Array[TvTab] = []
var _current_tab : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return


func start_game() -> void:
	started_game.emit()


func quit_game() -> void:
	get_tree().quit()


func resume_game() -> void:
	resumed_game.emit()


func open_tab(tab_name : String):
	for i in tabs.size():
		if tabs[i].name == tab_name:
			_current_tab = i
			tabs[i].reset_focus()
		
		tabs[i].set_visible(tabs[i].name == tab_name)


func get_focus_position() -> Vector2:
	return tabs[_current_tab].get_focus_position()


func get_current_tab() -> String:
	return tabs[_current_tab].name
