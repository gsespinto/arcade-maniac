extends Node3D
class_name TVsHolder

@export var game_viewport_manager : GameViewportManager

## Viewport texture that will be displayed on the current tv.
@export var game_viewport_texture : ViewportTexture

## Texture that will be displayed on idle tvs.
@export var idle_texture : Texture

## If true, will change back to the first TV
## once the game has ended by winning or losing
@export var reset_tv_on_end : bool = false

var _tvs : Array[TV] = []
var _current_tv_index : int = 0
var _default_tv : TV = null


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	# Get all child nodes that are tvs to store
	for child in get_children():
		if not child is TV:
			continue
		
		_tvs.append(child)
	
	assert(not _tvs.is_empty(), "TVsHolder must have at least on TV child node!")
	_default_tv = _tvs.front()
	
	# Set initial tv texture
	for i in _tvs.size():
		_tvs[i].set_texture(idle_texture)
	
	game_viewport_manager.on_game_changed.connect(_set_current_tv)
	game_viewport_manager.on_game_removed.connect(_remove_tv)
	game_viewport_manager.on_end.connect(_reset_tv)


# Sets current tv index to given value and 
# updates the previous and current tvs textures
func _set_current_tv(index : int) -> void:
	if index < 0:
		print("Couldn't set current tv as invalid index was given!")
		return
	
	index = index % _tvs.size()
	
	if _current_tv_index >= 0 and _current_tv_index < _tvs.size():
		_tvs[_current_tv_index].set_texture(idle_texture)
	_tvs[index].set_texture(game_viewport_texture)
	_current_tv_index = index


func get_current_tv() -> TV:
	return _tvs[_current_tv_index]


func _remove_tv(index : int) -> void:
	if _tvs.size() <= 1:
		return
	
	_tvs[index].set_texture(idle_texture)
	_tvs.remove_at(index)
	if _current_tv_index >= index:
		_current_tv_index -= 1


func _reset_tv() -> void:
	if not reset_tv_on_end:
		return
	
	if not _tvs.has(_default_tv):
		_tvs.insert(0, _default_tv)
	
	_set_current_tv(0)
