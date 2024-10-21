extends CharacterBody2D


const SPEED = 300.0


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction : Vector2 = Vector2(Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"))
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2(move_toward(velocity.x, 0, SPEED), 
			move_toward(velocity.y, 0, SPEED))

	move_and_slide()
