@tool
extends CharacterBody2D
class_name PongBall


@export var initial_speed : float = 200.0
@export var col_speed_increase_ratio : float = 0.1
@export var max_speed : float = 500.0  
@export var mov_direction : Vector2 = Vector2(1, 1)
@export var min_x_force : float = 0.1

@onready var _current_speed : float = initial_speed


func _ready() -> void:
	mov_direction = Vector2(1, randf_range(-1, 1)).normalized()
	if randf() > 0.5:
		mov_direction.x = -mov_direction.x


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	velocity = mov_direction * _current_speed

	move_and_slide()

	var col : KinematicCollision2D = get_last_slide_collision()
	if col != null:
		if col.get_collider().is_in_group("player"):
			_current_speed = clampf(_current_speed + _current_speed * col_speed_increase_ratio,
				initial_speed, max_speed)
		
		mov_direction = mov_direction.bounce(col.get_normal())
		mov_direction.x = sign(mov_direction.x) * max(abs(mov_direction.x), min_x_force)
