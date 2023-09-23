extends StaticBody2D

signal button_pressed(button: StaticBody2D, body: Node2D)
signal button_released(button: StaticBody2D, body: Node2D)

@export_enum("BLUE") var color
var frame

func _ready():
	match color:
		"BLUE": frame = 0
		"RED": frame = 2
		"GREEN": frame = 4
		"ORANGE": frame = 6

func on_button_pressed(body: Node2D):
	$Sprite2D.vframes += 1
	button_pressed.emit(self, body)

func on_button_released(body: Node2D):
	$Sprite2D.vframes -= 1
	button_released.emit(self, body)
