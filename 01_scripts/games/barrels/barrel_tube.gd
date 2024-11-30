## This Area2D makes the barrels unable to move 
## horizontally while insde it, so that they only fall.
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_set_barrel_can_move.bind(false))
	body_exited.connect(_set_barrel_can_move.bind(true))


func _set_barrel_can_move(body : Node2D, can_move : bool) -> void:
	if not body is Barrel:
		return
	
	body.can_move = can_move
