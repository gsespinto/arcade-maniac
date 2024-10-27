extends Node3D

# Unhandled input in the main viewport (such as UI events)
# won't be automatically propagated into the game viewport
# and as such, we mush manually push input


func _unhandled_input(event: InputEvent) -> void:
	for child in get_children():
		child.push_input(event)
