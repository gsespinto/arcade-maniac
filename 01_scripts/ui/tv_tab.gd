extends Control
class_name TvTab

signal changed_focus

@export var focusable_items : Array[Control] = []
var _current_focus : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if focusable_items.is_empty():
		return
	
	for item in focusable_items:
		if not is_instance_valid(item):
			continue
		
		item.focus_entered.connect(_on_item_focus.bind(item))


func _on_item_focus(item : Control):
	if not is_instance_valid(item):
		return
	
	_current_focus = focusable_items.find(item)
	changed_focus.emit()


func get_focus_position() -> Vector2:
	if focusable_items.is_empty():
		return get_rect().size / 2
	
	return focusable_items[_current_focus].get_screen_position()


func reset_focus():
	if focusable_items.is_empty():
		return
	
	_current_focus = 0
	focusable_items[_current_focus].grab_focus()


func focus_on_previous():
	focusable_items[_current_focus].grab_focus()
