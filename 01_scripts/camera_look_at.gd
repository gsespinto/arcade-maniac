extends Camera3D

const LOOK_AT_RADIUS : float = 1.0


@export var game_viewport_manager : GameViewportManager

## Sprite 3D that is rendering the 2D game subviewport.
@export var tvs_holder : TVsHolder

## Look at lerp weight to adjust smothness of movement.
@export_range(0.0, 1.0, 0.01) var lerp_weight : float = 1.0

var _look_at_pos : Vector3


func _ready() -> void:
	await get_tree().process_frame
	
	_look_at_pos = _get_normalized_look_at_pos()
	look_at(_get_look_at_pos(), Vector3.UP)


func _physics_process(_delta) -> void:
	# Lerp towards the current target look at position
	# so the movement is smoother.
	# TODO: Fix looking at the ceiling or floor when lerping this
	_look_at_pos = _look_at_pos.lerp(_get_normalized_look_at_pos(), lerp_weight)
	look_at(_look_at_pos, Vector3.UP)


# Returns global 3D position of the target 
# node 2D that is within the sprite 3D.
func _get_look_at_pos() -> Vector3:
	var sprite_3D : Sprite3D = tvs_holder.get_current_tv().sprite
	var target_node_pos : Vector2 = game_viewport_manager.get_look_at_pos()
	
	var local_pos : Vector2 = target_node_pos * sprite_3D.pixel_size \
		- sprite_3D.get_item_rect().size / 2 * sprite_3D.pixel_size
	
	return sprite_3D.to_global(Vector3(local_pos.x, -local_pos.y, 0))


# Returns look at pos normalized on the LOOK_AT_RADIUS
# This ensures the turn speed is the same between two
# look at positions that are at different distances from the camera
func _get_normalized_look_at_pos() -> Vector3:
	var direction : Vector3 = (_get_look_at_pos() - global_position).normalized()
	return global_position + direction.normalized()
