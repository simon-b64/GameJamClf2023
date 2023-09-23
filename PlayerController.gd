extends CharacterBody2D

@export var SPEED: int = 300.0
@export var JUMP_VELOCITY: int = -800

var JUMP_BUCKET_CONST: float = 0.4
var jump_bucket: int = JUMP_VELOCITY
var delta_since_latst_vel_add: int = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var jump_mult = min(1,max(0.1, delta * JUMP_BUCKET_CONST))
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		print(velocity.y)
		if Input.is_action_pressed("move_jump") and jump_bucket != JUMP_VELOCITY:
			velocity.y += jump_bucket * jump_mult
			jump_bucket *= 1 - jump_mult
	else:
		jump_bucket = JUMP_VELOCITY

	# Handle Jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_bucket * JUMP_BUCKET_CONST
		jump_bucket *= 1 - JUMP_BUCKET_CONST

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if velocity == Vector2.ZERO:
		$PlayerAnimationTree.get("parameters/playback").travel("Idle")
	else:
		$PlayerAnimationTree.set("parameters/Idle/blend_position", velocity.x)
		$PlayerAnimationTree.set("parameters/GroundMovement/blend_position", velocity.x)
		$PlayerAnimationTree.set("parameters/AirMovement/blend_position", velocity.y)
		if is_on_floor():
			$PlayerAnimationTree.get("parameters/playback").travel("GroundMovement")
		else:
			$PlayerAnimationTree.get("parameters/playback").travel("AirMovement")
		

	move_and_slide()
