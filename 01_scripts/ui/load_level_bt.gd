extends Button

@export var level : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(load_level)


func load_level():
	LoadingScreen.load_scene(level)
