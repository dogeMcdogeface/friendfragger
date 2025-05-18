extends CharacterBody3D


@export var health_max = 100
@onready var health = health_max

@export var mass = 80.0

@export var speed_ground = 5.0
@export var speed_fast = 8.0
@export var speed_air = 2.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity_y = 0.002

@export var pitch_max : float = 90  ##max pitch in degrees.
@export var pitch_min : float = -50 ##min pitch in degrees.



@export var kick_cooldown := 1.0  # seconds
var _kick_cooldown_timer := 0.0
@export var punch_cooldown := 0.2  # seconds
var _punch_cooldown_timer := 0.0

@export_range(0, 2, 1) var animationConstrained: int  = 0


func _process(delta: float) -> void:
	$Gizmo_Spine2.rotation = $Head.rotation

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
		
	_punch_cooldown_timer += delta
	var canPlayMelee = (animationConstrained == 0) and !$AnimationKick.is_playing() and !$AnimationPunch.is_playing()
	if Input.is_action_just_pressed("player_punch") and _punch_cooldown_timer > punch_cooldown and canPlayMelee:
		_punch_cooldown_timer = 0
		punch()
				
	_kick_cooldown_timer += delta
	if Input.is_action_just_pressed("player_kick") and _kick_cooldown_timer > kick_cooldown and canPlayMelee:
		_kick_cooldown_timer = 0
		kick()

	if Input.is_action_just_pressed("player_throw"):
		print("Throw")

	
	velocity = velocity.limit_length(10)
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		#print(collider)

		if collider is RigidBody3D:
			collider.apply_central_impulse(-collision.get_normal() * mass / 20)
		elif collider.has_method("getPushed"):
			collider.getPushed(-collision.get_normal() * mass / 20, collision.get_position() )
		
		if collider.has_method("heal") and health < health_max:
			heal( collider.heal(), delta)

func kick():
	$AnimationKick.play("kick")
	var closeObjects = $Kick.get_overlapping_bodies()
	print("Kick ", closeObjects)
	playMeleeSound("Kick")
	var kick_dir = -transform.basis.z.normalized() * 150
	for o in closeObjects:
		if o == self:
			continue
		if o.has_method("apply_impulse"):
			var random_offset = Vector3(
			randf_range(-0.5, 0.5),
			0.5,
			randf_range(-0.5, 0.5)
			)
			o.apply_impulse(kick_dir, random_offset )
		if o.has_method("attacked"):
			o.attacked("Kick",  kick_dir, 15)

func punch():
	$AnimationPunch.play("punch")
	var closeObjects = $Head/Punch.get_overlapping_bodies()
	print("Punch ", closeObjects)
	playMeleeSound("Punch")
	var punch_dir = -transform.basis.z.normalized() * 100
	for o in closeObjects:
		if o == self:
			continue
		if o.has_method("apply_impulse"):
			o.apply_impulse(punch_dir)
		if o.has_method("attacked"):
			o.attacked("Punch",  punch_dir, 8)
			
		


func playMeleeSound(meta):
	print("playing hit sound: ",meta)
	if(meta == "Punch"):
		$AudioStreamPlayer3D_Punch.play()
	if(meta == "Kick"):
		$AudioStreamPlayer3D_Kick.play()
	
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


func get_label_property(prop:String):
	if (prop == "Health"):
		return "(♥) %02d" % health


func heal(amt, delta):
	health += amt * delta
	health = clamp(health, 0, health_max)

func get_hurt(damage):
	print("Got hurt ",damage)
	health -= damage
	health = clamp(health, 0, health_max)
	if !$AudioStreamPlayer3D_Hurt.playing: 
		$AudioStreamPlayer3D_Hurt.play()
	if ! $AnimationShake.is_playing():
		print("playing")
		$AnimationShake.play("shake")
