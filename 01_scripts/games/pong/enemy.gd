@tool
extends CharacterBody2D

const RAYCAST_LENGTH : float = 1000

@export var speed : float = 300.0
@export var ball : PongBall

## Distance needed that the character needs 
## to be from the target position to move
@export var move_threshold : float = 2

@export_category("Prediction")

## When the ball enters this area, the enemy
## will predict the target position it needs to
## be to defend it. A bigger area means the enemy
## has more time to reach the predicted position,
## so the game is harder.
@export var prediction_area : Area2D
## Radius of the ball to be used in the prediction.
@export var ball_radius : float = 1.0
## Maximum number of wall bounces to calculate the prediction.
@export var max_bounces : int = 10

var _prediction_raycast : RayCast2D
var _target_position : float = 0

@export_category("Debug")
@export var debug_prediction : bool = false
var _prediction_points : Array[Vector2] = []


func _enter_tree() -> void:
	# Create raycast
	_prediction_raycast = RayCast2D.new()
	add_child(_prediction_raycast)
	_prediction_raycast.add_exception(ball)
	
	_target_position = global_position.y
	
	# In play mode, we want to predict the target position
	# each time the ball enters the prediction area
	if not Engine.is_editor_hint():
		prediction_area.body_entered.connect(_start_prediction)
		return


func _exit_tree() -> void:
	if is_instance_valid(_prediction_raycast):
		_prediction_raycast.queue_free()
	
	if not Engine.is_editor_hint():
		prediction_area.body_entered.disconnect(_start_prediction)


func _physics_process(delta: float) -> void:
	# In the editor, just draw the ball prediction
	if Engine.is_editor_hint():
		_start_prediction(ball)
		queue_redraw()
		return
	
	if abs(_target_position - global_position.y) > move_threshold:
		velocity.y = sign(_target_position - global_position.y) * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	# Force the character to not move horizontally
	velocity.x = 0

	move_and_slide()
	
	# We redraw the prediction while the character is moving
	# because the draw is in local space, which means it would
	# move with the enemy, we have to queue_redraw to keep the
	# draw in global space
	if velocity.length_squared() > 0 and debug_prediction:
		queue_redraw()


func _start_prediction(body : Node2D) -> void:
	if body != ball or not is_instance_valid(_prediction_raycast):
		return
	
	_prediction_points.clear()
	
	# If the ball isn't moving towards the enemy
	# No need to calculate a prediction
	if sign(ball.mov_direction.x) != sign(global_position.x - ball.global_position.x):
		return 
	
	# Start the predicion from the ball position
	# raycasting towards its current movement direction
	_prediction_raycast.global_position = ball.global_position
	var raycast_direction : Vector2 = ball.mov_direction.normalized() * RAYCAST_LENGTH
	_prediction_raycast.target_position = raycast_direction
	_prediction_raycast.force_raycast_update()
	var collider = _prediction_raycast.get_collider()
	
	_prediction_points.append(_prediction_raycast.global_position)
	
	# Bounce the raycast around the collision points
	# until it either collides with this character
	# or nothing at all, meaning we got the ball's end trajectory 
	while collider != null and collider != self:
		_prediction_raycast.global_position = _prediction_raycast.get_collision_point() - raycast_direction.normalized() * ball_radius
		raycast_direction = raycast_direction.bounce(_prediction_raycast.get_collision_normal())
		_prediction_raycast.target_position = raycast_direction
		_prediction_raycast.force_raycast_update()
		collider = _prediction_raycast.get_collider()
		
		_prediction_points.append(_prediction_raycast.global_position)
		
		# There *could* be a nearly infinite number of bounces
		# so we need to cap it so the game doesn't explode
		if _prediction_points.size() > max_bounces:
			break
	
	
	# Get the intersection point between the ball's final 
	# trajectory and this characters movement line
	var intersection_point = Geometry2D.line_intersects_line(
		_prediction_raycast.global_position, raycast_direction.normalized(),
		self.global_position, Vector2.UP)
	
	if intersection_point == null:
		intersection_point = Geometry2D.line_intersects_line(
			_prediction_raycast.global_position, raycast_direction.normalized(),
			self.global_position, Vector2.DOWN)
	
	assert(intersection_point != null, "There has to be an intersection point!")
	
	# The intersection point will be the next target position 
	# of the enemy so they may defend the ball
	_target_position = intersection_point.y
	_prediction_points.append(intersection_point)


# When debug_prediction flag is on, draws 
# the full trajectory prediction of the ball
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
	
	if not is_instance_valid(ball):
		warnings.append("Missing ball reference!\n")
	
	if not is_instance_valid(prediction_area):
		warnings.append("Missing prediction area reference!\n")
	
	return warnings
