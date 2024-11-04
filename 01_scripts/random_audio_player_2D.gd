extends Node
class_name RandomAudioPlayer2D

@export var audio_clips : Array[AudioStream]
var _audio_player : AudioStreamPlayer2D


# Called when the node enters the scene tree.
func _enter_tree() -> void:
	_audio_player = AudioStreamPlayer2D.new()
	add_child(_audio_player)


# Plays random clip from exported audio streams
func play():
	if not is_instance_valid(_audio_player):
		print("Couldn't play %s as the audio player isn't set up yet!" % [get_name()])
		return
	
	if audio_clips.is_empty():
		print("Couldn't play %s as there are no audio clips!" % [get_name()])
		return
	
	_audio_player.set_stream(audio_clips.pick_random())
	_audio_player.play()
