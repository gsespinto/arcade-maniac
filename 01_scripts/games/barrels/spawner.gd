extends Node2D

enum Direction{
	LEFT = -1,
	RIGHT = 1
}


@export var barrel_scene : PackedScene
@export var barrels_holder : Node2D
@export var initial_direction : Direction = Direction.RIGHT
@export var speed : float = 125.0


func spawn() -> void:
	var new_barrel : BarrelObstacle = barrel_scene.instantiate()
	barrels_holder.add_child(new_barrel)
	new_barrel.position = Vector2.ZERO
	new_barrel.launch(initial_direction, speed)
