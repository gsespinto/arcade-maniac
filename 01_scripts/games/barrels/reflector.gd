extends Area2D


@export_range(0.0, 1.0, 0.01) var reflect_chance : float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body : Node2D) -> void:
	if not body is BarrelObstacle:
		return
	
	if randf() <= reflect_chance:
		body.invert_direction()
