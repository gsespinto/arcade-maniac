extends Control

signal loaded_music

# Reference to the FileDialog node
@onready var file_dialog : FileDialog = $FileDialog

@export var default_audio_streams : Array[AudioStream] = []
var _user_audio_streams : Array[AudioStream] = []
var _current_music : int = -1


func _ready():
	file_dialog.files_selected.connect(_on_files_selected)
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.dir_selected.connect(_on_dir_selected)
	
	file_dialog.visibility_changed.connect(on_closed_file_dialog)
	
	loaded_music.emit()


func open_file_dialog():
	GameManager.set_tree_paused(true)
	file_dialog.popup_centered()


func on_closed_file_dialog():
	if file_dialog.visible:
		return
	
	GameManager.set_tree_paused(false)


# When files are selected
func _on_files_selected(files: Array):
	_user_audio_streams.clear()
	for file_path in files:
		_load_music_file(file_path)
	
	_current_music = 0
	loaded_music.emit()


# When files are selected
func _on_file_selected(file_path: String):
	_user_audio_streams.clear()
	_load_music_file(file_path)
	
	_current_music = 0
	loaded_music.emit()


func _on_dir_selected(dir_path : String):
	_user_audio_streams.clear()
	var dir = DirAccess.open(dir_path)
	for file in dir.get_files():
		_load_music_file(dir_path + "/" + file)
	
	_current_music = 0
	loaded_music.emit()


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
		_current_music = 0
	
	return music[_current_music]


func get_next_music() -> AudioStream:
	var music : Array[AudioStream] = get_music_streams()
	if music.is_empty():
		return null
	
	_current_music = (_current_music + 1) % music.size()
	return music[_current_music]


func get_previous_music() -> AudioStream:
	var music : Array[AudioStream] = get_music_streams()
	if music.is_empty():
		return null
	
	_current_music = _current_music - 1
	if _current_music < 0:
		_current_music = music.size() -1
	
	return music[_current_music]


func get_music_streams() -> Array[AudioStream]:
	if not _user_audio_streams.is_empty():
		return _user_audio_streams
	
	return default_audio_streams
