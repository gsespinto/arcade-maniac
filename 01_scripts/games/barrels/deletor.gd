## Area 2D responsible for deleting barrels and
## also making the player lose. It should be placed
## around the level out of bounds.
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body : Node2D) -> void:
	if body is Barrel:
		body.queue_free()
	elif body is BarrelPlayer:
		body.die()
