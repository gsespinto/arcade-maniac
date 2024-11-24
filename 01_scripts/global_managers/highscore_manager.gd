extends Node

const HIGHSCORE_COUNT : int = 5

signal updated_highscores(highscores : Array)
signal added_new_highscore

# Array of highscore data registered
# { time : float, date : DateTime }
var highscores : Array = []


func _enter_tree() -> void:
	if not DataManager.has_loaded_data:
		await DataManager.loaded_data
	
	# Get saved highscores
	highscores = DataManager.get_data("Highscores", "highscores", [])
	updated_highscores.emit(highscores)

	# Whenever the player wins the game
	# check if the time of that play was
	# a highscore
	GameManager.won.connect(check_current_highscore)


func check_current_highscore():
	# Snap time value so that it's rounded to the milisseconds
	var time : float = snapped(GameManager.current_time, 0.001)
	
	# If the highscores are all filled out and the 
	# lowest highscore is better than the current play
	# then it's for certain not a highscore
	if highscores.size() >= HIGHSCORE_COUNT and highscores.back().time < time:
		return
	
	var highscore_data : Dictionary = { 
			"time" : time, "date" : Time.get_date_dict_from_system()
		}
	
	# Insert the highscore on the correct poisition
	# In this game, the lower your time is, the greater
	# the highscore
	var has_added : bool = false
	for i in highscores.size():
		if highscores[i].time > time:
			highscores.insert(i, highscore_data)
			has_added = true
			break
	
	if not has_added:
		highscores.append(highscore_data)
	
	# Delete any highscore that is beyound the count
	if highscores.size() >= HIGHSCORE_COUNT:
		highscores.resize(HIGHSCORE_COUNT)
	
	updated_highscores.emit(highscores)
	added_new_highscore.emit()
	
	DataManager.set_data("Highscores", "highscores", highscores)
