extends TvTab

@export var highscore_items : Array[HighscoreItem] = []
@export var new_highscore_indicators : Array[Control] = []
@export var reset_button : Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_highscores(HighscoreManager.highscores)
	HighscoreManager.updated_highscores.connect(_update_highscores)
	
	_set_new_highscore(HighscoreManager.has_new_highscore)
	HighscoreManager.added_new_highscore.connect(_set_new_highscore.bind(true))


func reset_highscores():
	HighscoreManager.set_highscores([])


func _update_highscores(highscores : Array) -> void:
	if is_instance_valid(reset_button):
		reset_button.disabled = highscores.is_empty()
	
	for i in highscore_items.size():
		if i >= highscores.size():
			highscore_items[i].setup({})
			continue
		
		highscore_items[i].setup(highscores[i])


func _set_new_highscore(new_highscore : bool) -> void:
	for indicator in new_highscore_indicators:
		indicator.set_visible(new_highscore)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			HighscoreManager.has_new_highscore = false
			_set_new_highscore(false)
