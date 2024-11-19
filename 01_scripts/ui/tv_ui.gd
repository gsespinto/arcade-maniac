extends Control
## Node responsible to handle ui interactions within
## the tv interface (the game's HUD).
class_name TvUi

static var instance : TvUi


## Emitted when the focus target of the current tab changes
## useful to give audiovisual feedback 
signal changed_focus


## File path to the game scene to load to restart the game
@export var game_scene : String = ""

@export var tabs : Array[TvTab] = []
var _current_tab : int = 0
var _sub_tab_stack : Array[String]  = []

@export var final_time_label : Label


func _enter_tree() -> void:
	instance = self


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for tab in tabs:
		tab.changed_focus.connect(changed_focus.emit)
	
	GameManager.won.connect(set_final_time)


func start_game() -> void:
	GameManager.start()


func quit_game() -> void:
	get_tree().quit()


func resume_game() -> void:
	GameManager.unpause()


func restart_game() -> void:
	LoadingScreen.load_scene(game_scene)


func open_music() -> void:
	MusicManager.open_file_dialog()


func open_sub_tab(tab_name : String) -> void:
	_sub_tab_stack.append(tabs[_current_tab].name)
	open_tab(tab_name)


func close_sub_tab() -> void:
	if _sub_tab_stack.is_empty():
		return

	open_tab(_sub_tab_stack.pop_back(), false)


# Sets tab with target name visible and hides all the rest
# Returns whether it successfully opened a tab
func open_tab(tab_name : String, reset_focus : bool = true) -> bool:
	var success : bool = false
	for i in tabs.size():
		if tabs[i].name == tab_name:
			_current_tab = i
			if reset_focus:
				tabs[i].reset_focus()
			else:
				tabs[i].focus_on_previous()
			
			success = true
		
		tabs[i].set_visible(tabs[i].name == tab_name)
	
	if not success:
		print("'%s' tab doesn't exist in tv ui!" % [tab_name])
	
	return success


func get_focus_position() -> Vector2:
	return tabs[_current_tab].get_focus_position()


func get_current_tab() -> String:
	return tabs[_current_tab].name


func set_final_time():
	final_time_label.set_text(GameManager.get_current_time_string())


var toggle : bool = false
func _input(event: InputEvent) -> void:
	return
	
	# TODO: This is giving problems in the pause menu
	if event.is_action_pressed("ui_cancel", false):
		TranslationServer.set_locale("en" if toggle else "pt")
		toggle = not toggle
		close_sub_tab()
