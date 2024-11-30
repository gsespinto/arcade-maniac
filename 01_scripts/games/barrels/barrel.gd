extends CharacterBody2D
class_name Barrel

enum Direction{
	LEFT = -1,
	RIGHT = 1
}

const SPEED : float = 125.0

@export var player_detection_area : Area2D

@export var direction : Direction = Direction.RIGHT 

var can_move : bool = true
var _in_stairs : bool = false



func _ready() -> void:
	assert(is_instance_valid(player_detection_area), "Barrel requires a player detection area!")
	player_detection_area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = 0.0 if (_in_stairs or not can_move) else direction * SPEED
	
	move_and_slide()


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
	direction = -direction
