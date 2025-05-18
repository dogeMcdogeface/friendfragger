extends CharacterBody3D

@export var health: float = 10  # 
@export var dead = false 
var absorber = null

@export var damage: float = 10  # 


@export var speed = 5.0

@export var mass: float = 5.0  # 
@export var rotation_speed: float = 5.0  # Radians per second

@export var stunnedTime: float = 1.0  # Seconds
var stunnedTimer = stunnedTime

@onready var Nav = $NavigationAgent3D
var navtarget

func _ready() -> void:
	Globals.mob_count += 1

func _process(delta: float) -> void:
	if dead:return
	if(!navtarget):
		selectNewNavTarget()
	else:
		Nav.target_position = navtarget.global_position

	#if Nav.is_navigation_finished():
		#selectNewNavTarget()
		
	if(navtarget):
		$Model/Gizmo_eye.look_at(navtarget.global_position)
		$Model/Gizmo_eye.rotation_degrees.x = -$Model/Gizmo_eye.rotation_degrees.x
	$Model/Gizmo_eye.rotation_degrees.x = clampf($Model/Gizmo_eye.rotation_degrees.x, -17, 17)
	$Model/Gizmo_eye.rotation_degrees.z = clampf($Model/Gizmo_eye.rotation_degrees.z, -13, 13)
	
	#print(Nav.is_navigation_finished(), Globals.NavTargets)

func selectNewNavTarget():
	navtarget = Globals.NavTargets.pick_random()
	

func _physics_process(delta: float) -> void:
	
	
	if absorber:
		var d = (absorber.get_absorb_position() - global_position)
		if d.length() < 1:remove()
		velocity = d.normalized() * speed / 5.
		move_and_slide()
		return
	
	if dead and !$VisibleOnScreenNotifier3D.is_on_screen() and $Timer_Remove.is_stopped():
		remove()
	
	stunnedTimer += delta
	var nextPos = Nav.get_next_path_position()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 5* delta)
		velocity.z = lerp(velocity.z, 0.0, 5* delta)

	if stunnedTimer > stunnedTime and !dead:

		# Point the Gizmo toward the next position
		if $Gizmo.global_position.distance_to(nextPos) > 1:
			$Gizmo.look_at(nextPos)



		if is_on_floor():
			if !$AudioStreamPlayer3D_walk.playing: 
				$AudioStreamPlayer3D_walk.play()
			
			# Smoothly rotate this object toward Gizmo's Y-rotation
			var current_yaw = global_rotation.y
			var target_yaw = $Gizmo.global_rotation.y
			global_rotation.y = lerp_angle(current_yaw, target_yaw, rotation_speed * delta)
			
			if navtarget and $Gizmo.global_position.distance_to(navtarget.global_position) > 1.5:
				# Move forward in facing direction
				var forward = -global_transform.basis.z  # -Z is forward in Godot
				var move_direction = forward * speed
				velocity.x = move_direction.x
				velocity.z = move_direction.z
			else:
				velocity.x = 0
				velocity.z = 0
			
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			collider.apply_central_impulse(-collision.get_normal() * mass)
		if collider.has_method("absorbEnemy"):
			collider.absorbEnemy(self)
			getAbsorbed(collider)

func attacked(type: String, impulse: Vector3, damage: float):
	health -= damage
	if health <= 0: 
		die()
		
	$AudioStreamPlayer3D_hit.play()

	stunnedTimer = 0
	if type == "Punch":
		impulse.y = 0
	if type == "Kick":
		impulse.y = 80
	print("got attacked",impulse )
	velocity = impulse / mass
	

func getPushed(impulse: Vector3, position: Vector3):
	if !dead:
		return

	# Set velocity
	velocity = impulse
	# Compute local position of impact
	var local_offset = to_local(position)
	# Compute rotational effect (simplified torque around Y axis)
	var torque_strength = 5.0  # You can export this if desired
	# Cross product in XZ plane gives us direction of torque
	var torque = local_offset.x * impulse.z - local_offset.z * impulse.x
	# Apply rotation around Y axis based on torque
	# For simplicity, convert torque to a small Y rotation
	rotation.y += torque * torque_strength * 0.001  # scaling factor

func getAbsorbed(_absorber:Node3D):
	die()
	collision_layer = 2
	collision_mask = 2
	absorber = _absorber

func die():
	if dead: return
	dead = true
	$Timer_Remove.start()
	$AudioStreamPlayer3D_death.play()
	$CollisionShape3D.disabled = true
	$Model/eyeball.get_surface_override_material(0).emission_enabled = false


func remove():
	print("clearing")
	Globals.mob_count -= 1
	queue_free()


func _on_hurt_box_body_entered(body: Node3D) -> void:
	print(body)

	if body.has_method("get_hurt"):
		body.get_hurt(damage)
		print(body)
	pass # Replace with function body.
