extends Node3D
class_name CharacterViewport

@export var remote_arm_animator : AnimationPlayer
@export var timer_arm_animator : AnimationPlayer
@export var blend_time : float = 0.05


func play_animation(animation : String) -> void:
	if is_instance_valid(remote_arm_animator) \
			and remote_arm_animator.has_animation(animation):
		remote_arm_animator.play(animation, blend_time)
	
	if is_instance_valid(timer_arm_animator) \
			and timer_arm_animator.has_animation(animation):
		timer_arm_animator.play(animation, blend_time)
