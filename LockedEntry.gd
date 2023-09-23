extends StaticBody2D

signal locked_entry_entered(entry: StaticBody2D, body: Node2D)

func _on_locked_entry_entered(body: Node2D):
	locked_entry_entered.emit(self, body)
