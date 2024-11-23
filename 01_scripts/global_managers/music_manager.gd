extends Control

signal music_changed

# Reference to the FileDialog node
@onready var file_dialog : FileDialog = $FileDialog

@export var default_audio_streams : Array[AudioStream] = []
var _user_audio_streams : Array[AudioStream] = []

var _current_music : int = 0


func _ready():
	file_dialog.files_selected.connect(_on_files_selected)
	file_dialog.visibility_changed.connect(on_closed_file_dialog)
	
	_set_current_music(DataManager.get_data("Music", "current_music", 0))
	_load_user_music()


func _load_user_music():
	if not OptionsManager.music_files.is_empty():
		_load_files(OptionsManager.music_files)
	music_changed.emit()


func open_file_dialog():
	GameManager.set_tree_paused(true)
	file_dialog.popup_centered()


func on_closed_file_dialog():
	if file_dialog.visible:
		return
	
	GameManager.set_tree_paused(false)


# When files are selected
func _on_files_selected(files: PackedStringArray):
	OptionsManager.set_music_files(files)
	_set_current_music(0)
	_load_files(files)


func _load_files(files : PackedStringArray):
	_user_audio_streams.clear()
	for file_path in files:
		_load_music_file(file_path)
	music_changed.emit()


func _load_music_file(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var file_extension : String = Array(file_path.split(".")).back()
		match file_extension:
			"mp3":
				var mp3_stream : AudioStreamMP3 = AudioStreamMP3.new()
				mp3_stream.data = file.get_buffer(file.get_length())
				_user_audio_streams.append(mp3_stream)
			
			"wav":
				var wav_stream : AudioStreamWAV = AudioStreamWAV.new()
				wav_stream.data = file.get_buffer(file.get_length())
				_user_audio_streams.append(wav_stream)
			
			_:
				prints("Failed to open file:", file_path, "Unrecognized file extension!")
		
		file.close()
	else:
		print("Failed to open file:", file_path)



func get_current_music() -> AudioStream:
	var music : Array[AudioStream] = get_music_streams()
	if music.is_empty():
		return null
	
	if _current_music < 0 or _current_music >= music.size():
		_set_current_music(0)
	
	return music[_current_music]


func get_next_music() -> AudioStream:
	var music : Array[AudioStream] = get_music_streams()
	if music.is_empty():
		return null
	
	_set_current_music((_current_music + 1) % music.size())
	return music[_current_music]


func get_previous_music() -> AudioStream:
	var music : Array[AudioStream] = get_music_streams()
	if music.is_empty():
		return null
	
	if _current_music <= 0:
		_set_current_music(music.size() - 1)
	else:
		_set_current_music(_current_music - 1)
	
	return music[_current_music]


func get_music_streams() -> Array[AudioStream]:
	if not _user_audio_streams.is_empty():
		return _user_audio_streams
	
	return default_audio_streams


func _set_current_music(music_index : int):
	_current_music = music_index
	DataManager.set_data("Music", "current_music", _current_music)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_music"):
		get_next_music()
		music_changed.emit()
	elif event.is_action_pressed("previous_music"):
		get_previous_music()
		music_changed.emit()
