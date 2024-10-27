extends Control
class_name TvTab

signal changed_focus

@export var buttons : Array[Button] = []
var _current_bt : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if buttons.is_empty():
		return
	
	for bt in buttons:
		bt.focus_entered.connect(_on_button_focus.bind(bt))


func _on_button_focus(button : Button):
	if button == null:
		return
	
	_current_bt = buttons.find(button)
	changed_focus.emit()


func get_focus_position() -> Vector2:
	if buttons.is_empty():
		return Vector2.ZERO
	
	return buttons[_current_bt].get_rect().position


func reset_focus():
	_current_bt = 0
	buttons[_current_bt].grab_focus()
