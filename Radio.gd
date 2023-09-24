extends Area2D

signal radio_entered(radio: Area2D, body: Node2D)

func _on_radio_entered(body: Node2D):
	radio_entered.emit(self, body)
