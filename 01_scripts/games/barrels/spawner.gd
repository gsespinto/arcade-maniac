extends Node2D


## Barrel packed scene to instantiate.
@export var barrel_scene : PackedScene

## Node that will hold the instances of the barrels,
## move this node to adjust the spawn position and
## order it in the tree to define the draw order.
@export var barrels_holder : Node2D

## Direction in which the barrels should move initially.
@export var initial_direction : Barrel.Direction = Barrel.Direction.RIGHT


func spawn() -> void:
	var new_barrel : Barrel = barrel_scene.instantiate()
	barrels_holder.add_child(new_barrel)
	new_barrel.position = Vector2.ZERO
	new_barrel.direction = initial_direction
