extends Label3D

@export var OverrideText:String
@export var targetPropertyNode:Node
@export var targetPropertyName:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.get_frames_drawn() % 5 == 0 :
		if !OverrideText.is_empty():
			text = OverrideText
		elif targetPropertyNode and targetPropertyNode.has_method("get_label_property"):
			text = targetPropertyNode.get_label_property(targetPropertyName)
		resizeAutoLabel()
		pass


func resizeAutoLabel():
	var parent = get_parent()
	if !parent or !parent.has_method("get_aabb"):return
	var target_width = parent.get_aabb().size * 0.9
	var source_width = get_aabb().size

	if source_width.x != 0 and source_width.y != 0:
		var scale_factor_x = target_width.x / source_width.x
		var scale_factor_y = target_width.y / source_width.y

		scale.x = scale_factor_x  # Only scale X (width)
		scale.y = scale_factor_y  # Only scale X (width)
