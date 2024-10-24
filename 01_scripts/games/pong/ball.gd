extends CharacterBody2D


@export var initial_speed : float = 200.0
@export var col_speed_increase_ratio : float = 0.1
@export var max_speed : float = 500.0  
@export var mov_direction : Vector2 = Vector2(1, 1)

@onready var _current_speed : float = initial_speed


func _physics_process(delta: float) -> void:
	velocity = mov_direction * _current_speed

	move_and_slide()

	var col : KinematicCollision2D = get_last_slide_collision()
	if col != null:
		if col.get_collider().is_in_group("player"):
			_current_speed = clampf(_current_speed + _current_speed * col_speed_increase_ratio,
				initial_speed, max_speed)
		
		mov_direction = mov_direction.bounce(col.get_normal())
