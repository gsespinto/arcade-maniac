extends CharacterBody2D


@export var speed : float = 300.0


func _physics_process(delta: float) -> void:
	var direction : float = Input.get_axis("move_up", "move_down")
	if direction:
		velocity.y = direction * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	# Force the character to not move horizontally
	velocity.x = 0

	move_and_slide()
