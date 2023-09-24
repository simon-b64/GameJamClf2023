@tool
extends StaticBody2D

@export var buttons: Array[StaticBody2D]
var should_be_closed := true
var amount_of_buttons_pressed: int = 0

func _ready():
	connect_buttons(buttons)

func connect_buttons(buttons):
	for button in buttons:
		button.button_pressed.connect(on_button_pressed)
		button.button_released.connect(on_button_released)

func on_button_pressed(button, body):
	should_be_closed = false
	amount_of_buttons_pressed += 1
	$AnimationTree.get("parameters/playback").travel("open")
	print("Button Pressed")

func on_button_released(button):
	amount_of_buttons_pressed -= 1
	if amount_of_buttons_pressed != 0:
		return
	should_be_closed = true
	$CollisionShape2D.disabled = false
	$AnimationTree.get("parameters/playback").travel("close")
	print("Button Released")

func on_anim_finished(anim):
	if anim == "open" && !should_be_closed:
		$CollisionShape2D.disabled = true
