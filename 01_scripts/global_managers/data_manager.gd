extends Node

const FILE_PATH : String = "user://data.oops"

signal loaded_data

var has_loaded_data : bool = false
var _data : ConfigFile = null


func _enter_tree() -> void:
	_load_data()


func _exit_tree() -> void:
	_save_data()


func _load_data():
	_data = ConfigFile.new()
	_data.load(FILE_PATH)
	loaded_data.emit()
	has_loaded_data = true


func _save_data():
	_data.save(FILE_PATH)


func set_data(section : String, key : String, value):
	_data.set_value(section, key, value)


func get_data(section : String, key : String, default_value) -> Variant:
	if not _data.has_section_key(section, key):
		_data.set_value(section, key, default_value)
	
	return _data.get_value(section, key, default_value)
