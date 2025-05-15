extends CharacterBody3D


@export var speed_ground = 5.0
@export var speed_fast = 8.0
@export var speed_air = 2.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity_y = 0.002

@export var pitch_max : float = 90  ##max pitch in degrees.
@export var pitch_min : float = -50 ##min pitch in degrees.


@export_range(0, 2, 1) var animationConstrained: int  = 0


func _physics_process(delta: float) -> void:
	var speed = speed_ground

	if Input.is_action_pressed("player_sprint"):
		speed = speed_fast

	if not is_on_floor():
		velocity += get_gravity() * delta 	# Add the gravity.
		speed = speed_air


	# Handle jump.
	if Input.is_action_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		var tmpVelocity = Vector2(velocity.x, velocity.z)
		tmpVelocity = tmpVelocity.move_toward( Vector2.ZERO, speed) #uniform interpolation \
		velocity.x = tmpVelocity.x
		velocity.z = tmpVelocity.y

	move_and_slide()
	
	
func _unhandled_input(event)-> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var movement = event.relative
		rotate_y(- (movement.x * 0.01 * mouse_sensitivity_y ))
		orthonormalize()
		$Head.rotate_x(- (movement.y * 0.01 * mouse_sensitivity_y ))
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
		$Head.orthonormalize()

		if animationConstrained == 2:
			rotation.y = clamp(rotation.y, deg_to_rad(0), deg_to_rad(0))
			$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(0), deg_to_rad(0))
		elif animationConstrained == 1:
					rotation.y = clamp(rotation.y, deg_to_rad(-20), deg_to_rad(20))
					$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-30), deg_to_rad(30))
