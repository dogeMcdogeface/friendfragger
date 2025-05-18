extends Node3D

@export var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enabled:
		Globals.NavTargets.append(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
