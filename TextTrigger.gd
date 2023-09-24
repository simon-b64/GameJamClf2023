@tool
extends Area2D

signal text_trigger_entered(text_trigger: Area2D, body: Node2D)

@export var show_text: bool:
	set(value):
		show_text = value
		notify_property_list_changed()
		
@export_multiline var text: String

func _on_text_trigger_entered(body: Node2D):
	text_trigger_entered.emit(self, body)
