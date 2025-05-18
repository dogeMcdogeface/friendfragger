@tool
extends MeshInstance3D

@export var borderSize = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		#mesh = mesh.duplicate()
		$Monitor_Border.mesh = $Monitor_Border.mesh.duplicate()
	generateBorder()
	generateCollisionBox()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint() and Engine.get_frames_drawn() % 5 == 0 :
		generateBorder()
		generateCollisionBox()
		var a = find_children("*", "Label3D", true,  true)
		for label in a:
			label.position.z = get_aabb().end.z + 0.01
			
	pass
	
func generateBorder():
	$Monitor_Border.mesh.size.x = mesh.size.x + borderSize 
	$Monitor_Border.mesh.size.y = mesh.size.y + borderSize 
	$Monitor_Border.mesh.size.z = mesh.size.z

func generateCollisionBox():
	$MonitorCollider/CollisionShape3D.shape.size = $Monitor_Border.mesh.size
	$MonitorCollider/CollisionShape3D.position = Vector3.ZERO
	
