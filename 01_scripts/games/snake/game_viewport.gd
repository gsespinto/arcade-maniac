@tool
extends GameViewport

enum CellState{
	EMPTY,
	SNAKE,
	APPLE
}

@export_category("Grid")
@export var grid_size : Vector2i = Vector2(800, 600):
	set(value):
		if value.x <= 1:
			value.x = 1
		if value.y <= 1:
			value.y = 1
		grid_size = value
		_cell_size = Vector2(float(grid_size.x) / columns, float(grid_size.y) / rows)
		queue_redraw()

@export var rows : int = 12:
	set(value):
		if value <= 0:
			value = 0
		rows = value
		_cell_size = Vector2(float(grid_size.x) / columns, float(grid_size.y) / rows)
		queue_redraw()

@export var columns : int = 24:
	set(value):
		if value <= 0:
			value = 0
		columns = value
		_cell_size = Vector2(float(grid_size.x) / columns, float(grid_size.y) / rows)
		queue_redraw()

@export_category("Snake")
@export var move_time : Array[float] = [0.25]:
	set(value):
		if value.is_empty():
			value.append(0.25)
		
		for i in value.size():
			if value[i] < 0.01:
				value[i] = 0.01
			
		move_time = value

@export var snake_line_packed_scene : PackedScene


@export_category("Ball")
@export var ball_radius : float = 20.0:
	set(value):
		ball_radius = value
		queue_redraw()
@export var ball_color : Color = Color.RED:
	set(value):
		ball_color = value
		queue_redraw()


@export_category("Preview")
@export var preview_color : Color = Color.GREEN:
	set(value):
		preview_color = value
		queue_redraw()

@export_range(1.0, 10.0, 0.01) var preview_width : float = 1.0:
	set(value):
		preview_width = value
		queue_redraw()

@export var debug_in_game : bool = false


var _current_snake : Line2D = null
var _move_timer : Timer = null
var _movement_input : Vector2i = Vector2i.ZERO
var _movement_direction : Vector2i = Vector2i.RIGHT
var _snake_points : Array[Vector2i] = []

var _grid_state : Array[Array]
var _available_cells : Array[Array]

var _current_apple : Vector2i = Vector2i.ZERO
var _cell_size : Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_cell_size = Vector2(float(grid_size.x) / columns, float(grid_size.y) / rows)
	
	if Engine.is_editor_hint():
		return
	
	for c in columns:
		_grid_state.append(range(rows))
		_available_cells.append(range(rows))
		_grid_state[c].fill(CellState.EMPTY)
	
	_set_apple_cell()
	
	_snake_points.append_array([
		Vector2i(columns / 2, rows / 2),
		Vector2i(columns / 2 - 1, rows / 2)
	])
	for point in _snake_points:
		_set_cell_state(point, CellState.SNAKE)
	
	# Buffer point, to add to tail when picking up point
	_snake_points.append(Vector2i.ZERO)
	
	
	_current_snake = snake_line_packed_scene.instantiate()
	_current_snake.clear_points()
	_current_snake.width = min(_cell_size.x, _cell_size.y)
	add_child(_current_snake)
	_update_snake()
	
	move_time = move_time.duplicate()
	_move_timer = Timer.new()
	_move_timer.wait_time = move_time.pop_front()
	_move_timer.autostart = true
	_move_timer.timeout.connect(_move)
	add_child(_move_timer)
	
	super._ready()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_get_movement_input()
	look_at_target.set_position(_get_cell_position(_current_apple))


func _draw() -> void:
	draw_circle(_get_cell_position(_current_apple), ball_radius, ball_color)

	if Engine.is_editor_hint() or debug_in_game:
		_preview_grid()


func _get_movement_input() -> void:
	var direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		_movement_input = Vector2i(direction.x, direction.y)


func _move() -> void:
	if not is_instance_valid(_current_snake) or _snake_points.is_empty():
		return
	
	if _movement_input != Vector2i.ZERO:
		var x : int = sign(_movement_input.x)
		if x * _movement_direction.x < 0:
			x = _movement_direction.x
		
		if x != 0:
			_movement_input.y = 0
		
		var y : int = sign(_movement_input.y)
		if y * _movement_direction.y < 0:
			y = _movement_direction.y
		
		_movement_direction = Vector2i(x, y)
	
	
	var range : Array = range(_snake_points.size())
	range.reverse()
	for i in range:
		if i == 0:
			continue
		
		_snake_points[i] = _snake_points[i - 1]
	
	_snake_points[0] += _movement_direction
	if _check_collision():
		_update_snake()


func _set_cell_state(cell_id : Vector2i, state : CellState):
	_grid_state[cell_id.x][cell_id.y] = state
	
	if state == CellState.EMPTY:
		if not _available_cells[cell_id.x].has([cell_id.y]):
			_available_cells[cell_id.x].append(cell_id.y)
	else:
		_available_cells[cell_id.x].erase(cell_id.y)


func _get_cell_state(cell_id : Vector2i) -> CellState:
	return _grid_state[cell_id.x][cell_id.y]


func _check_collision() -> bool:
	if (_snake_points.front().x < 0 or _snake_points.front().x >= columns) or \
			(_snake_points.front().y < 0 or _snake_points.front().y >= rows) or \
			_get_cell_state(_snake_points.front()) == CellState.SNAKE:
		lose()
		return false
	
	if _snake_points.front() == _current_apple:
		_snake_points.append(_snake_points.back())
		_set_apple_cell()
		if move_time.size() > 0:
			_move_timer.wait_time = move_time.pop_front()
	
	_set_cell_state(_snake_points.back(), CellState.EMPTY)
	_set_cell_state(_snake_points.front(), CellState.SNAKE)
	return true


func _update_snake() -> void:
	if not is_instance_valid(_current_snake) or _snake_points.is_empty():
		return
	
	var column_sep : float = float(grid_size.x) / columns
	var row_sep : float = float(grid_size.y) / rows
	
	var snake_line_positions : PackedVector2Array = []
	for i in _snake_points.size() - 1:
		snake_line_positions.append(
			_get_cell_position(_snake_points[i])
		)
	
	_current_snake.set_points(snake_line_positions)


func _get_cell_position(cell_id : Vector2i) -> Vector2:
	return _cell_size * Vector2(cell_id) + _cell_size / 2


func _set_apple_cell() -> void:
	var col : int = randi_range(0, _available_cells.size() - 1)
	_current_apple = Vector2i(col, _available_cells[col].pick_random())
	_set_cell_state(_current_apple, CellState.APPLE)
	queue_redraw()


func _preview_grid() -> void:
	for c in columns:
		var x_pos : float = _cell_size.x * c
		var y_end : float = _cell_size.y * rows
		
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, y_end), preview_color, preview_width)
	
	for r in rows:
		var x_end : float = _cell_size.x * columns
		var y_pos : float = _cell_size.y * r
		
		draw_line(Vector2(0, y_pos), Vector2(x_end, y_pos), preview_color, preview_width)
