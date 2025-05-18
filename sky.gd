extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var noiseoffset = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = get_viewport().get_camera_3d().global_position.x  
	position.z = get_viewport().get_camera_3d().global_position.z 

	noiseoffset  += 20.0 * delta / 2
	texture.noise.offset.z = int(noiseoffset) * 2
	pass
