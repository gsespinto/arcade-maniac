extends Area2D

@export_range(0.0, 1.0, 0.01) var enter_chance : float = 1.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body : Node2D) -> void:
	if randf() > enter_chance:
		return
	
	if body.has_method("set_in_stairs"):
		body.set_in_stairs(true)


func _on_body_exited(body : Node2D) -> void:
	if body.has_method("set_in_stairs"):
		body.set_in_stairs(false)
