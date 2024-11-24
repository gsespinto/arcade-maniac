extends Control
class_name HighscoreItem

@export var default_value : String = "---"
@export var time_label : Label
@export var date_label : Label


func _ready() -> void:
	assert(is_instance_valid(time_label), "Highscore item must have a valid time label!")
	assert(is_instance_valid(date_label), "Highscore item must have a valid date label!")


# Sets highscore item information
func setup(highscore_data : Dictionary):
	# If there's no data, set labels with default value
	if highscore_data.is_empty():
		time_label.set_text(default_value)
		date_label.set_text(default_value)
		return
	
	time_label.set_text(Utils.get_time_string(highscore_data.time))
	
	# Format store highscore date to be DD/MM/AAAA
	var date : String = str(highscore_data.date.day).pad_zeros(2) + "/" + \
		str(highscore_data.date.month).pad_zeros(2) + "/" + \
		str(highscore_data.date.year)
	date_label.set_text(date)
