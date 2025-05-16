extends Node3D

@export var rotation_period: float = 2.0  # Time (in seconds) to complete one full 360° rotation

func _process(delta: float) -> void:
	# Calculate degrees (or radians) to rotate this frame
	var rotation_speed = TAU / rotation_period  # TAU = 2π, full rotation in radians
	rotate_y(rotation_speed * delta)
