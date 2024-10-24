extends GameViewport

@export var win_area : Area2D
@export var lose_area : Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	win_area.body_entered.connect(_entered_win_area)
	lose_area.body_entered.connect(_entered_lose_area)


func _entered_win_area(body : Node2D) -> void:
	super.win()


func _entered_lose_area(body : Node2D) -> void:
	super.lose()
