extends Control

signal typed
signal finished

## Level to load once the player finishes the intro.
@export var game_level : String = ""

## Label that displays the intro text. It's a rich text label
## so that it has the smart wrapping on all supported locales.
## Should have the locale key as it's initial text, so that
## we may get the target translation at _ready().
@export var rich_label : RichTextLabel

## Time between adding each letter of the intro text.
@export var typing_time : float = 0.1

## Substring that signals to take a break from typing.
@export var break_indicator : String = "[br]"
## Time the typing will be paused when in break and 
## the typing character will be blinking.
@export var break_time : float = 0.25

## Time that the type character's visibility is toggled when in break.
@export var blink_time : float = 0.25

var _intro_text : String = ""
var _current_char : int = 0

var _typing_timer : Timer = null
var _blinking_timer : Timer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the translated intro text from the rich label
	_intro_text = rich_label.get_parsed_text()
	rich_label.set_text("")
	
	# Setup timers
	_typing_timer = Timer.new()
	_typing_timer.wait_time = typing_time
	_typing_timer.autostart = true
	_typing_timer.timeout.connect(_write)
	add_child(_typing_timer)
	
	_blinking_timer = Timer.new()
	_blinking_timer.wait_time = blink_time
	_blinking_timer.autostart = true
	_blinking_timer.timeout.connect(_blink)
	add_child(_blinking_timer)
	_blinking_timer.set_paused(true)


# Sets the rich label text to write the intro 
# text's characters one by one. Triggers typing break
# when break_indicator is found.
func _write() -> void:
	if _current_char >= _intro_text.length():
		return
	
	# If the next characters to be typed are the break indicator
	# remove them from the intro text and trigger break
	var remaining_text : String = _intro_text.substr(_current_char)
	if remaining_text.begins_with(break_indicator):
		_intro_text = _intro_text.substr(0, _current_char) + remaining_text.trim_prefix(break_indicator)
		_take_break()
		return
	
	_current_char += 1
	var current_text : String = _intro_text.substr(0, _current_char)
	
	# When we've typed the whole intro text, emit finished
	if _current_char >= _intro_text.length():
		finished.emit()
	# If we're still typing, add typing character at the end of the text
	else:
		current_text += "|"
	
	rich_label.set_text(current_text)
	typed.emit()


# Pauses typing for break time
func _take_break() -> void:
	_typing_timer.set_paused(true)
	_blinking_timer.set_paused(false)

	await get_tree().create_timer(break_time).timeout

	_typing_timer.set_paused(false)
	_blinking_timer.set_paused(true)


# Toggles typing character in rich label text
func _blink() -> void:
	if rich_label.get_text().ends_with("|"):
		rich_label.set_text(rich_label.get_text().trim_suffix("|"))
	else:
		rich_label.set_text(rich_label.get_text() + "|")


# Loads game level
func go_to_game() -> void:
	LoadingScreen.load_scene(game_level)


# If we're typing, skips the intro to the end
func skip() -> void:
	if _current_char >= _intro_text.length():
		return
	
	_intro_text = _intro_text.replace(break_indicator, "")
	_current_char = _intro_text.length()
	rich_label.set_text(_intro_text)
	
	_typing_timer.stop()
	_blinking_timer.stop()
	
	typed.emit()
	finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		skip()
