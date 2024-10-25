extends PongCharacter


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	var direction : float = Input.get_axis("move_up", "move_down")
	if direction:
		velocity.y = direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
