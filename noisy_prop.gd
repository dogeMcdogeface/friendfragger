extends RigidBody3D

@export var collision_sound_cooldown := 0.1  # seconds
@export var collision_sound_min_speed := 1  
var last_sound_time := -100.0  # initialized far in the past

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	if linear_velocity.length() > collision_sound_min_speed:
		var now = Time.get_ticks_msec() / 1000.0  # convert to seconds
		if now - last_sound_time >= collision_sound_cooldown:
			$AudioStreamPlayer3D_hit.play()
			last_sound_time = now


func attacked(type: String, impulse: Vector3, damage: float):
	$AudioStreamPlayer3D_hit.play()

	
