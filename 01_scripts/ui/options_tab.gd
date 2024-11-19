extends TvTab

## Button to change language, will change text to
## show current locale string
@export var fullscreen_bt : Button

## Game volume slider, sets up min and max values according to
## OptionsManager settings, and toggles the editable state
## when there's ´ui_accept´ input and the slider has focus.
@export var volume_slider : Slider

## Music volume slider, sets up min and max values according to
## OptionsManager settings, and toggles the editable state
## when there's ´ui_accept´ input and the slider has focus.
@export var music_slider : Slider

## Button to change language, will change text to
## show current locale string
@export var locale_bt : Button


func _ready() -> void:
	# Set initial fullscreen text state
	_update_fullscreen_button_text()
	
	# Set initial locales text state
	_update_locales_button_text()
	
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
	
	if is_instance_valid(fullscreen_bt):
		var suffix : String = "_ON" if OptionsManager.is_fullscreen else "_OFF"
		_update_fullscreen_button_text()


func _update_fullscreen_button_text():
	if not is_instance_valid(fullscreen_bt):
		return
	
	var suffix : String = "_ON" if OptionsManager.is_fullscreen else "_OFF"
	fullscreen_bt.set_text("STR_FULLSCREEN" + suffix)


func cycle_locales():
	OptionsManager.cycle_locales()
	_update_locales_button_text()


func _update_locales_button_text():
	if not is_instance_valid(locale_bt):
		return
	
	locale_bt.set_text(OptionsManager.get_current_locale_name().to_upper())


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
