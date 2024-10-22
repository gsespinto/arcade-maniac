extends CharacterBody2D


const SPEED = 300.0
const JUMP_FORCE = 4000.0


func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y -= JUMP_FORCE
	else:
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction : float = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
