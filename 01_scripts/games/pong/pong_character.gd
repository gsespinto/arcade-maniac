extends CharacterBody2D
class_name PongCharacter

const SPEED : float = 300.0
var _x_pos : float = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_x_pos = position.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# Force the character to not move horizontally
	position.x = _x_pos
	velocity.x = 0
