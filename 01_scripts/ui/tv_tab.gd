extends Control
class_name TvTab

signal updated_focus

@export var focusable_items : Array[Control] = []
var _current_focus : int


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if focusable_items.is_empty():
		return
	
	visibility_changed.connect(_connect_items_focus, CONNECT_DEFERRED)


# We connect and disconnect to the focus_entered signal of the items
# to avoid having the be called when the tab is not visible
func _connect_items_focus():
	for item in focusable_items:
		if not is_instance_valid(item):
			continue
		
		if visible:
			item.focus_entered.connect(_on_item_focus.bind(item))
		else:
			item.focus_entered.disconnect(_on_item_focus)


func _on_item_focus(item : Control):
	if not is_instance_valid(item):
		return
	
	if "disabled" in item and item.disabled:
		focusable_items[_current_focus].grab_focus()
		return
	
	_current_focus = focusable_items.find(item)
	updated_focus.emit()


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


# Whenever we pressed an item from this tab
# emit signal for visual/audio feedback
# and set input has handled so it doesn't 
# propagate to the remaining ui tabs
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept", false):
		return
	
	if not is_visible_in_tree():
		return
	
	for item in focusable_items:
		if item.has_focus():
			updated_focus.emit()
			get_viewport().set_input_as_handled()
			break
