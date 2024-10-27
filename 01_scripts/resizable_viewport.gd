extends SubViewport

@export var reference_rect : Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(reference_rect != null, "Resizable viewport must have a reference rect!")
	reference_rect.resized.connect(resize_viewport)
	resize_viewport()


func resize_viewport() -> void:
	set_size(Vector2i(reference_rect.get_rect().size))
