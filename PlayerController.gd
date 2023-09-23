extends CharacterBody2D

@export var SPEED: int = 300.0
@export var JUMP_VELOCITY: int = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
