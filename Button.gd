@tool
extends StaticBody2D

signal button_pressed(button: StaticBody2D, body: Node2D)
signal button_released(button: StaticBody2D, body: Node2D)

enum Colors {BLUE = 0, RED = 2, GREEN = 4, ORANGE = 6}
enum ButtonTypes {ACTIVE, TOGGLE, TIMER}
@export var color := Colors.BLUE:
	set(value):
		color = value
		$Sprite2D.frame = value
@export var type := ButtonTypes.TOGGLE
@export var timer_duration = 0

func on_button_pressed(body: Node2D):
	if body == self:
		return
	$Sprite2D.frame += 1
	button_pressed.emit(self, body)

func on_button_released(body: Node2D):
	$Sprite2D.frame -= 1
	button_released.emit(self, body)
