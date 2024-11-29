extends CharacterBody2D
class_name BarrelObstacle

@export var player_detection_area : Area2D

var _speed : float
var _current_direction : float
var _in_stairs : bool = false


func _ready() -> void:
	assert(is_instance_valid(player_detection_area), "Barrel requires a player detection area!")
	player_detection_area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = 0 if _in_stairs else _current_direction * _speed
	
	move_and_slide()


func launch(direction : float, speed : float) -> void:
	_current_direction = direction
	_speed = speed


func _on_body_entered(body : Node2D) -> void:
	if not body is BarrelPlayer:
		return
	
	body.die()


func set_in_stairs(in_stairs : bool) -> void:
	if _in_stairs == in_stairs:
		return
	
	_in_stairs = in_stairs
	
	if _in_stairs:
		set_collision_mask_value(1, false)
	else:
		invert_direction()
		set_collision_mask_value(1, true)


func invert_direction() -> void:
	_current_direction = -_current_direction
