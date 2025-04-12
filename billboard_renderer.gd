extends Node3D

@export var lock_elevation = true
@export var rotation_snapping:float = 8
@onready var rotation_snap_factor = rotation_snapping/360

@onready var Gizmo = $BillboardViewport/Gizmo
@onready var Camera = $BillboardViewport/Gizmo/Camera3D
@onready var ActiveCamera = get_viewport().get_camera_3d()

@onready var ParentMesh = get_node("../MeshInstance3D")

static var curr_layer = 0

func _ready() -> void:
	ParentMesh.layers = 0
	#ParentMesh.set_layer_mask_value(3, true)
	ParentMesh.set_layer_mask_value(10 + curr_layer, true) 
	Camera.cull_mask = ParentMesh.layers
	curr_layer += 1
	updateBounds()

func updateBounds():
	var bounds = get_node_aabb(get_parent_node_3d(), true)
	var longest = bounds.end.length()*2
	Camera.size = longest
	$BillboardMesh.mesh.size = Vector2(longest,longest)
	
func _process(delta: float) -> void:
	Gizmo.global_position = global_position
	
	Gizmo.look_at(ActiveCamera.global_position,Vector3.UP, true)
	var rounded_global_rotation_degrees = ((rotation_snap_factor*Gizmo.global_rotation_degrees).round()/rotation_snap_factor)
	var rounded_parent_rotation_degrees =  global_rotation_degrees -((rotation_snap_factor*global_rotation_degrees).round()/rotation_snap_factor)
	#print(rotation_snap_factor, Gizmo.global_rotation_degrees, rounded_global_rotation_degrees,(rotation_snap_factor*Gizmo.global_rotation_degrees))
	var combined_rotation_degrees = rounded_global_rotation_degrees + rounded_parent_rotation_degrees
	Gizmo.global_rotation_degrees = combined_rotation_degrees
	if lock_elevation:
		Gizmo.global_rotation_degrees.x = 0
	#Gizmo.global_rotation_degrees = rounded_global_rotation_degrees
	
	
## Return the [AABB] of the node.
func get_node_aabb(node : Node, exclude_top_level_transform: bool = true) -> AABB:
	var bounds : AABB = AABB()

  # Do not include children that is queued for deletion
	if (node == self) or node.is_queued_for_deletion():
		return bounds

	# Get the aabb of the visual instance
	if node is VisualInstance3D:
		bounds = node.get_aabb();

  # Recurse through all children
	for child in node.get_children():
		var child_bounds : AABB = get_node_aabb(child, false)
		if bounds.size == Vector3.ZERO:
			bounds = child_bounds
		else:
			bounds = bounds.merge(child_bounds)

	if !exclude_top_level_transform:
		bounds = node.transform * bounds

	return bounds
