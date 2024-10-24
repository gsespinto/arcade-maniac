@tool
extends CharacterBody2D


const SPEED = 300.0

@export var ball : CharacterBody2D
@export var ball_radius : float = 1.0
@export var prediction_area : Area2D
@export var acceptance_radius : float = 2

var _prediction_raycast : RayCast2D
var _target_position : float = 0

@export_category("Debug")
@export var debug_prediction : bool = false
var _prediction_points : Array[Vector2] = []


func _enter_tree() -> void:
	_prediction_raycast = RayCast2D.new()
	add_child(_prediction_raycast)
	_prediction_raycast.add_exception(ball)
	
	if not Engine.is_editor_hint():
		prediction_area.body_entered.connect(_start_prediction)
		return


func _exit_tree() -> void:
	if is_instance_valid(_prediction_raycast):
		_prediction_raycast.queue_free()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		_start_prediction(ball)
		queue_redraw()
		return
	
	if abs(_target_position - global_position.y) > acceptance_radius:
		velocity.y = sign(_target_position - global_position.y) * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	if velocity.length_squared() > 0:
		queue_redraw()


func _start_prediction(body : Node2D) -> void:
	if body != ball or not is_instance_valid(_prediction_raycast):
		return
	
	_prediction_points.clear()
	
	_prediction_raycast.global_position = ball.global_position
	var raycast_direction : Vector2 = ball.mov_direction.normalized() * 10000
	_prediction_raycast.target_position = raycast_direction
	_prediction_raycast.force_raycast_update()
	
	var collider = _prediction_raycast.get_collider()
	while collider != null and collider != self:
		_prediction_points.append(_prediction_raycast.global_position)
	
		_prediction_raycast.global_position = _prediction_raycast.get_collision_point() - raycast_direction.normalized() * ball_radius
		raycast_direction = raycast_direction.bounce(_prediction_raycast.get_collision_normal())
		_prediction_raycast.target_position = raycast_direction
		_prediction_raycast.force_raycast_update()
		collider = _prediction_raycast.get_collider()
	
	_prediction_points.append(_prediction_raycast.global_position)
	
	var intersection_point = Geometry2D.line_intersects_line(
		_prediction_raycast.global_position, raycast_direction.normalized(),
		self.global_position, Vector2.UP)
	
	if intersection_point == null:
		intersection_point = Geometry2D.line_intersects_line(
			_prediction_raycast.global_position, raycast_direction.normalized(),
			self.global_position, Vector2.DOWN)
	
	if intersection_point == null:
		_target_position = position.y
	else:
		_target_position = intersection_point.y
	
	_prediction_points.append(intersection_point)


func _draw() -> void:
	if not debug_prediction:
		return
	
	for i in _prediction_points.size():
		if i == 0:
			continue
		
		draw_circle(to_local(_prediction_points[i]), ball_radius, Color.RED, false, 2)
		draw_line(to_local(_prediction_points[i - 1]), to_local(_prediction_points[i]), Color.RED, 10)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : Array[String] = []
	
	if ball == null:
		warnings.append("Missing ball reference!")
	
	return warnings
