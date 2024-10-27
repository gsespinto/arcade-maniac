extends Node3D
class_name CharacterViewport

@export var animator : AnimationPlayer
@export var blend_time : float = 0.05


func play_animation(animation : String) -> void:
	if not is_instance_valid(animator):
		return
	
	animator.play(animation, blend_time)
