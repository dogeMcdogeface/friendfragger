extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = get_viewport().get_camera_3d().position.x
	position.z = get_viewport().get_camera_3d().position.z
	pass
