extends CanvasLayer

@export var animator : AnimationPlayer
var _scene_to_load : String = ""

signal loaded


func _ready():
	if not is_instance_valid(animator):
		return
	
	animator.animation_finished.connect(_on_animation_finished)


func load_scene(file_path : String):
	if file_path.is_empty():
		return
	
	_scene_to_load = file_path
	animator.play("load")
	show()


func _start_loading_scene():
	get_tree().change_scene_to_file(_scene_to_load)
	animator.play("unload")
	loaded.emit()


func _on_animation_finished(animation : String):
	match animation:
		"unload":
			hide()
