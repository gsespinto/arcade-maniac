extends Camera3D


## Sprite 3D that is rendering the 2D game subviewport.
@export var tvs_holder : TVsHolder

## 2D node within the subviewport the camera is supposed to follow.
@export var target_node_2D : Node2D

## Look at lerp weight to adjust smothness of movement.
@export_range(0.0, 1.0, 0.01) var lerp_weight : float = 1.0

var _look_at_pos : Vector3


func _ready() -> void:
	_look_at_pos = get_look_at_pos()


func _physics_process(delta) -> void:
	# Lerp towards the current target look at position
	# so the movement is smoother.
	_look_at_pos = _look_at_pos.lerp(get_look_at_pos(), lerp_weight)
	look_at(_look_at_pos, Vector3.UP)


# Returns global 3D position of the target 
# node 2D that is within the sprite 3D.
func get_look_at_pos() -> Vector3:
	var sprite_3D : Sprite3D = tvs_holder.get_current_tv().sprite
	
	var local_pos : Vector2 = target_node_2D.position * sprite_3D.pixel_size \
		- sprite_3D.get_item_rect().size / 2 * sprite_3D.pixel_size
	
	return sprite_3D.to_global(Vector3(local_pos.x, -local_pos.y, 0))
