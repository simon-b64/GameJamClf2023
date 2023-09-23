extends Area2D

signal key_entered(key: Area2D, body: Node2D)

func _on_body_entered(body: Node2D):
	key_entered.emit(self, body)
