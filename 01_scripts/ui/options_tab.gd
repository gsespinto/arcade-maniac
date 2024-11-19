extends TvTab

## Fullscreen button, will append to its text 'ON' or 'OFF' 
## according to the current fullscreen state.
@export var fullscreen_bt : Button
var _original_fullscreen_bt_text : String = ""

## Game volume slider, sets up min and max values according to
## OptionsManager settings, and toggles the editable state
## when there's ´ui_accept´ input and the slider has focus.
@export var volume_slider : Slider

## Music volume slider, sets up min and max values according to
## OptionsManager settings, and toggles the editable state
## when there's ´ui_accept´ input and the slider has focus.
@export var music_slider : Slider


func _ready() -> void:
	# Set initial fullscreen text state
	if is_instance_valid(fullscreen_bt):
		_original_fullscreen_bt_text = fullscreen_bt.text
		fullscreen_bt.set_text(_original_fullscreen_bt_text +
			("ON" if OptionsManager.is_fullscreen else "OFF"))
	
	# Set up game volume slider
	if is_instance_valid(volume_slider):
		volume_slider.min_value = OptionsManager.MIN_GAME_VOLUME
		volume_slider.max_value = OptionsManager.MAX_GAME_VOLUME
		volume_slider.set_value_no_signal(OptionsManager.game_volume)
		# When the slider loses focus, ensure it stops being editable
		volume_slider.focus_exited.connect(volume_slider.set_editable.bind(false))
	
	# Set up game volume slider
	if is_instance_valid(music_slider):
		music_slider.min_value = OptionsManager.MIN_MUSIC_VOLUME
		music_slider.max_value = OptionsManager.MAX_MUSIC_VOLUME
		music_slider.set_value_no_signal(OptionsManager.music_volume)
		# When the slider loses focus, ensure it stops being editable
		music_slider.focus_exited.connect(music_slider.set_editable.bind(false))
	
	super._ready()


func toggle_fullscreen():
	OptionsManager.toggle_fullscreen()
	
	# Update fullscreen button text
	if is_instance_valid(fullscreen_bt):
		fullscreen_bt.set_text(_original_fullscreen_bt_text +
			("ON" if OptionsManager.is_fullscreen else "OFF"))


func set_game_volume(volume_db : float):
	OptionsManager.set_game_volume(volume_db)


func set_music_volume(volume_db : float):
	OptionsManager.set_music_volume(volume_db)


# Toggle the editable state of the slider
# when there's ´ui_accept´ input and it has focus
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept", false):
		if is_instance_valid(volume_slider) and volume_slider.has_focus():
			volume_slider.editable = not volume_slider.editable
		
		if is_instance_valid(music_slider) and music_slider.has_focus():
			music_slider.editable = not music_slider.editable
