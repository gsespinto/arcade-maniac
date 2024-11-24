extends Node2D
class_name GameViewport

@export var look_at_target : Node2D

signal on_won
signal on_lost
signal on_sfx(sfx : AudioStream)

var has_won : bool = false

@export_category("SFX")
@export var win_sfx : AudioStream
@export var lose_sfx : AudioStream


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func win() -> void:
	has_won = true
	on_sfx.emit(win_sfx)
	on_won.emit()
	set_process_mode(Node.PROCESS_MODE_DISABLED)


func lose() -> void:
	on_sfx.emit(lose_sfx)
	on_lost.emit()
	set_process_mode(Node.PROCESS_MODE_DISABLED)


func _on_visibility_changed():
	if not visible:
		return
	
	if has_won:
		set_process_mode(Node.PROCESS_MODE_DISABLED)


func play_sfx(sfx : AudioStream) -> void:
	on_sfx.emit(sfx)
