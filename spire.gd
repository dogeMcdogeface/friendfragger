extends CSGCylinder3D

@onready var Spire_Rib_emission = $CSGCombiner3D/SpireRib.material.emission_texture.noise
@export var Spire_Rib_emission_speed = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Spire_Rib_emission.offset.y += Spire_Rib_emission_speed * delta
	Spire_Rib_emission.offset.z += Spire_Rib_emission_speed * delta * 0.5
	pass

func get_absorb_position():
	return $absorbPoint.global_position
func absorbEnemy(enemy:Node3D):
	print("Spire absorbs ", enemy)
