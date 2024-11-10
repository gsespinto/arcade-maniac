extends Node3D
class_name CharacterViewport

@export var remote_arm_animator : AnimationPlayer
@export var timer_arm_animator : AnimationPlayer
@export var blend_time : float = 0.05

@export var minutes_label : Label
@export var seconds_label : Label
@export var milisseconds_label : Label


func _ready() -> void:
	GameManager.started_timer.connect(play_animation.bind("TimerPress"))
	GameManager.stopped_timer.connect(play_animation.bind("TimerPress"))


func _process(delta: float) -> void:
	_update_time_labels()


func play_animation(animation : String) -> void:
	if is_instance_valid(remote_arm_animator) \
			and remote_arm_animator.has_animation(animation):
		remote_arm_animator.play(animation, blend_time)
	
	if is_instance_valid(timer_arm_animator) \
			and timer_arm_animator.has_animation(animation):
		timer_arm_animator.play(animation, blend_time)


func _update_time_labels() -> void:
	var time_info : PackedStringArray = _get_time_array(GameManager.current_time) 
	minutes_label.set_text(time_info[0])
	seconds_label.set_text(time_info[1])
	milisseconds_label.set_text(time_info[2])


func _get_time_array(total_seconds: float) -> PackedStringArray:
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hhmmss_string:String = "%02d:%05.2f" % [minutes, seconds]
	hhmmss_string = hhmmss_string.replace(".", ":")
	return hhmmss_string.split(":")
