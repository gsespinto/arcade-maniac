extends GameViewport

## Should be on a mask layer that only has the pong ball.
@export var win_area : Area2D

## Should be on a mask layer that only has the pong ball.
@export var lose_area : Area2D

@export var ball : PongBall

@export_category("SFX")
@export var wall_sfx : AudioStream
@export var player_sfx : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	win_area.body_entered.connect(_entered_win_area)
	lose_area.body_entered.connect(_entered_lose_area)
	ball.on_wall_collision.connect(play_sfx.bind(wall_sfx))
	ball.on_player_collision.connect(play_sfx.bind(player_sfx))


func _entered_win_area(body : Node2D) -> void:
	super.win()


func _entered_lose_area(body : Node2D) -> void:
	super.lose()
