extends Node3D

@export var music_player : AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player.set_volume_db(OptionsManager.music_volume)
	music_player.finished.connect(_play_next_music)
	MusicManager.loaded_music.connect(_play_current_music)
	_play_current_music()


func _play_current_music():
	music_player.set_stream(MusicManager.get_current_music())
	music_player.play()


func _play_next_music():
	music_player.set_stream(MusicManager.get_next_music())
	music_player.play()
