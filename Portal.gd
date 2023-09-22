extends Area2D

var player = null

func _on_door_body_entered(body):
	if body.get_name() != "Player":
		return
	player = body
	
func _on_door_body_exit(body):
	if body.get_name() != "Player":
		return
	player = null

func _process(delta):
	if player == null:
		return
	print(self.get_transform().x - player.get_transform().x)
	pass
