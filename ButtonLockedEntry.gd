@tool
extends StaticBody2D

@export var button: StaticBody2D
var should_be_closed := true

func _ready():
	connect_button(button)

func connect_button(button):
	button.button_pressed.connect(on_button_pressed)
	button.button_released.connect(on_button_released)

func on_button_pressed(button, body):
	should_be_closed = false
	$AnimationTree.get("parameters/playback").travel("open")
	print("Button Pressed")

func on_button_released(button):
	should_be_closed = true
	$CollisionShape2D.disabled = false
	$AnimationTree.get("parameters/playback").travel("close")
	print("Button Released")

func on_anim_finished(anim):
	if anim == "open" && !should_be_closed:
		$CollisionShape2D.disabled = true
