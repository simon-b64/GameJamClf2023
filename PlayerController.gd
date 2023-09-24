extends CharacterBody2D

@export var SPEED: int = 300.0
@export var JUMP_VELOCITY: int = -900
@export var TARGET_OFFSET: int = 100

var MAX_Y_DOWN_VELOCITY = 1500
var JUMP_BUCKET_CONST: float = 0.3
var jump_bucket: int = JUMP_VELOCITY
var delta_since_latst_vel_add: int = 0
var last_direction: int

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var jump_mult = min(1,max(0.1, delta**2 * JUMP_BUCKET_CONST))
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if Input.is_action_pressed("move_jump") && velocity.y < 0:
			velocity.y += jump_bucket * jump_mult
			jump_bucket *= 1 - jump_mult
		else:
			jump_bucket = 0
	else:
		jump_bucket = JUMP_VELOCITY

	# Handle Jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_bucket * JUMP_BUCKET_CONST
		jump_bucket *= 1 - JUMP_BUCKET_CONST
		
	# Limit Y velocity to not get infinit gravity acceleration
	# TODO: Discuss if this is good, because we could get a "glide"
	velocity.y = min(MAX_Y_DOWN_VELOCITY, velocity.y)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		last_direction = direction
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
		
	handle_camera(delta)
	move_and_slide()

func handle_camera(delta: float):
	var screen_height = get_viewport_rect().size.y
	var clamped_y_velocity = min(0.8, max(0.01, abs(velocity.y)/1500))
	var target_position = Vector2(sign(last_direction) * TARGET_OFFSET, sign(velocity.y) * screen_height / 2 * clamped_y_velocity)
	var camera_speed = Vector2(delta * (target_position.x - $Camera2D.offset.x) * 2, delta * (target_position.y - $Camera2D.offset.y) * 3)
	if target_position.y > $Camera2D.offset.y:
		$Camera2D.offset.y = min($Camera2D.offset.y + camera_speed.y, target_position.y)
	else:
		$Camera2D.offset.y = max($Camera2D.offset.y + camera_speed.y, target_position.y)
	if target_position.x > $Camera2D.offset.x:
		$Camera2D.offset.x = min($Camera2D.offset.x + camera_speed.x, target_position.x)
	else:
		$Camera2D.offset.x = max($Camera2D.offset.x + camera_speed.x, target_position.x)
	print(target_position)

func hide_thoughts():
	$Book.visible = false

func display_text(text: String):
	$Book.visible = true
	$Book/Control/Label.text = text
