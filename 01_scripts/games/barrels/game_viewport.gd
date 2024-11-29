extends GameViewport

## Area 2D in which the player needs to enter to win this game.
@export var win_area : Area2D
@export var jump_sfx : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	assert(look_at_target is BarrelPlayer, "In the game the look at target must be the player!")
	look_at_target.died.connect(lose)
	look_at_target.jumped.connect(play_sfx.bind(jump_sfx))
	win_area.body_entered.connect(_check_win)


func _check_win(body : Node2D) -> void:
	if not body is BarrelPlayer:
		return
	
	win()
