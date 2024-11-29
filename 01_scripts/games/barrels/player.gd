extends CharacterBody2D
class_name BarrelPlayer

signal died


@export var speed = 300.0
@export var jump_force = 400.0
@export var collision_shape : CollisionShape2D

var _in_stairs : bool = false
var _is_dead : bool = false

func _physics_process(delta: float) -> void:
	if _is_dead:
		velocity.x = 0
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
		move_and_slide()
		return
	
	if _in_stairs:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction : float = Input.get_axis("ui_up", "ui_down")
		if direction:
			velocity.y = direction * speed
		else:
			velocity.y = move_toward(velocity.y, 0, speed)
	else:
		if is_on_floor():
			velocity.y = 0
			if Input.is_action_just_pressed("ui_up"):
				velocity.y -= jump_force
		else:
			velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction : float = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func set_in_stairs(in_stairs : bool):
	_in_stairs = in_stairs


func die() -> void:
	if _is_dead:
		return
	
	velocity = Vector2.ZERO
	velocity.y -= jump_force
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if is_instance_valid(collision_shape):
		collision_shape.set_disabled(true)
	
	_is_dead = true
	died.emit()
