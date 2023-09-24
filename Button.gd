@tool
extends StaticBody2D

signal button_pressed(button: StaticBody2D, body: Node2D)
signal button_released(button: StaticBody2D)

enum Colors {BLUE = 0, RED = 2, GREEN = 4, ORANGE = 6}
enum ButtonTypes {ACTIVE, TOGGLE, TIMER}
@export var color := Colors.BLUE:
	set(value):
		color = value
		$Sprite2D.frame = value
@export var type := ButtonTypes.TOGGLE:
	set(value):
		type = value
		notify_property_list_changed()
var timer_duration: float = 0
var timer := Timer.new()
var is_pressed := false
var is_blocked := false
var should_release := false

func _get_property_list():
	var property_usage = PROPERTY_USAGE_NO_EDITOR
	
	if type == ButtonTypes.TIMER:
		property_usage = PROPERTY_USAGE_DEFAULT
	
	var properties = []
	properties.append({
		"name": "timer_duration",
		"type": TYPE_FLOAT,
		"usage": property_usage,
	})
	return properties

func _init():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(func(): should_release = true)

func _physics_process(delta: float):
	if should_release && !is_blocked:
		release_button()

func on_button_pressed(body: Node2D):
	is_blocked = true
	if type == ButtonTypes.TIMER:
		timer.stop()
	if body == self || is_pressed:
		return
	is_pressed = true
	$Sprite2D.frame = color + 1
	button_pressed.emit(self, body)

func on_button_released(body: Node2D):
	is_blocked = false
	if (type == ButtonTypes.TIMER):
		start_timer()
	if type != ButtonTypes.TOGGLE:
		return
	should_release = true

func release_button():
	is_pressed = false
	should_release = false
	$Sprite2D.frame = color
	button_released.emit(self)

func start_timer():
	timer.wait_time = timer_duration
	timer.start()
