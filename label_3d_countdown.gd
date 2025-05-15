extends Label3D

@export var targetAnimation:AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var timeleft = targetAnimation.current_animation_length-targetAnimation.current_animation_position
	text = "%05.2f" % timeleft
	pass
