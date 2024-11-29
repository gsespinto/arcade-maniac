extends CharacterBody2D
class_name BarrelPlayer

signal died

@export var speed = 300.0
@export var jump_force = 400.0

## This collision shape is disabled when the 
## player dies so that they fall through the level.
@export var collision_shape : CollisionShape2D

var _in_stairs : bool = false
var _is_dead : bool = false


func _physics_process(delta: float) -> void:
	# When the player dies, just fall through the level
	if _is_dead:
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
		move_and_slide()
		return
	
	# When in stairs, the player has control 
	# over their vertical movement
	if _in_stairs:
		var vertical_dir : float = Input.get_axis("ui_up", "ui_down")
		if vertical_dir:
			velocity.y = vertical_dir * speed
		else:
			velocity.y = move_toward(velocity.y, 0, speed)
	
	else:
		if is_on_floor():
			velocity.y = 0
			if Input.is_action_just_pressed("ui_up"):
				velocity.y -= jump_force
		else:
			velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	var horizontal_dir : float = Input.get_axis("ui_left", "ui_right")
	if horizontal_dir:
		velocity.x = horizontal_dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


# Method called by the stairs area
func set_in_stairs(in_stairs : bool):
	_in_stairs = in_stairs


# Triggers the death state once
func die() -> void:
	if _is_dead:
		return
	
	# On the lose state, this game will be paused
	# so change the player's process mode to
	# enable it to still move
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Jump before starting to fall
	velocity = Vector2.ZERO
	velocity.y -= jump_force
	
	# Disable collisions so that it can fall through the level
	if is_instance_valid(collision_shape):
		collision_shape.set_disabled(true)
	
	_is_dead = true
	died.emit()
