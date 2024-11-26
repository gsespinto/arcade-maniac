## This area is responsible for reflecting the
## movement direction of some barrels that enter it.
extends Area2D

## Percentile chance of the barrel being reflected.
@export_range(0.0, 1.0, 0.01) var reflect_chance : float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body : Node2D) -> void:
	if not body is Barrel:
		return
	
	if randf() <= reflect_chance:
		body.invert_direction()
