extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_use_accumulated_input(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event)-> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_abscond"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
