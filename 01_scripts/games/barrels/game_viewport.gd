extends GameViewport

@export var win_area : Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	win_area.body_entered.connect(_check_win)
	look_at_target.died.connect(lose)


func _check_win(body : Node2D) -> void:
	if not body is BarrelPlayer:
		return
	
	win()
