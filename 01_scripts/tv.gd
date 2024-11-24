extends Node3D
class_name TV


@export var sprite : Sprite3D
@export var sfx_audio_player : AudioStreamPlayer3D
@export var idle_audio_player : AudioStreamPlayer3D


func set_texture(texture : Texture) -> void:
	sprite.set_texture(texture)


func play_sfx(sfx : AudioStream):
	if not is_instance_valid(sfx_audio_player):
		print("%s doesn't have a valid sfx audio player!" % [get_name()])
		return
	
	sfx_audio_player.stop()
	sfx_audio_player.set_stream(sfx)
	sfx_audio_player.play()


func stop_sfx():
	if not is_instance_valid(sfx_audio_player):
		print("%s doesn't have a valid sfx audio player!" % [get_name()])
		return
	
	sfx_audio_player.stop()


func play_idle():
	if not is_instance_valid(sfx_audio_player):
		print("%s doesn't have a valid idle audio player!" % [get_name()])
		return
	
	idle_audio_player.play()


func stop_idle():
	if not is_instance_valid(sfx_audio_player):
		print("%s doesn't have a valid idle audio player!" % [get_name()])
		return
	
	idle_audio_player.stop()
