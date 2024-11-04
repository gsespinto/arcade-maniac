extends Node3D
class_name TV


@export var sprite : Sprite3D
@export var audio_player : AudioStreamPlayer3D


func set_texture(texture : Texture) -> void:
	sprite.set_texture(texture)


func play_sfx(sfx : AudioStream):
	if not is_instance_valid(audio_player):
		print("%s doesn't have a valid audio player!" % [get_name()])
		return
	
	audio_player.stop()
	audio_player.set_stream(sfx)
	audio_player.play()


func stop_sfx():
	if not is_instance_valid(audio_player):
		print("%s doesn't have a valid audio player!" % [get_name()])
		return
	
	audio_player.stop()
