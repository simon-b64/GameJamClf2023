extends Area2D

signal portal_entered(portal: Area2D)
signal portal_exited(portal: Area2D)
signal portal_teleported

var direction

func _on_door_body_entered(body: Node2D):
	if body.get_name() != "Player":
		return
	direction = self.position - body.position
	print(self.position)
	print(direction)
	portal_entered.emit(self)
	
func _on_door_body_exit(body: Node2D):
	if body.get_name() != "Player":
		return
	print(self.position - body.position)
	portal_exited.emit(self)
