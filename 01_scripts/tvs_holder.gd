extends Node3D
class_name TVsHolder

## Viewport texture that will be displayed on the current tv.
@export var game_viewport_texture : ViewportTexture
## Texture that will be displayed on idle tvs.
@export var idle_texture : Texture

var _tvs : Array[TV] = []
var _current_tv_index : int = 0


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	# Get all child nodes that are tvs to store
	for child in get_children():
		if not child is TV:
			continue
		
		_tvs.append(child)
	
	assert(not _tvs.is_empty(), "TVsHolder must have at least on TV child node!")
	
	# Set initial tv texture
	for i in _tvs.size():
		if i == _current_tv_index:
			_tvs[i].set_texture(game_viewport_texture)
		else:
			_tvs[i].set_texture(idle_texture)


# Sets current tv index to given value and 
# updates the previous and current tvs textures
func _set_current_tv(index : int) -> void:
	if index < 0 or index >= _tvs.size():
		print("Couldn't set current tv as invalid index was given!")
		return
	
	_tvs[_current_tv_index].set_texture(idle_texture)
	_tvs[index].set_texture(game_viewport_texture)
	_current_tv_index = index


func get_current_tv() -> TV:
	return _tvs[_current_tv_index]
