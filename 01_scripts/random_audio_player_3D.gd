extends AudioStreamPlayer3D
class_name RandomAudioPlayer3D

@export var audio_clips : Array[AudioStream]


# Plays random clip from exported audio streams
func play_random():
	if audio_clips.is_empty():
		print("Couldn't play %s as there are no audio clips!" % [get_name()])
		return
	
	set_stream(audio_clips.pick_random())
	play()
