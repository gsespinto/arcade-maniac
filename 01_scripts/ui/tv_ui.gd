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


# Sets tab with target name visible and hides all the rest
# Returns whether it successfully opened a tab
func open_tab(tab_name : String) -> bool:
	var success : bool = false
	for i in tabs.size():
		if tabs[i].name == tab_name:
			_current_tab = i
			tabs[i].reset_focus()
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
