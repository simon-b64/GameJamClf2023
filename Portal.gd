extends Node2D

signal portal_entered(portal: Node2D, body: Node2D)
signal portal_exited(portal: Node2D, body: Node2D)
signal tunnel_entered(portal: Node2D, body: Node2D)
signal tunnel_exited(portal: Node2D, body: Node2D)

@export var portal_channel: int

func _on_portal_entered(body: Node2D):
	portal_entered.emit(self, body)
	
func _on_portal_exit(body: Node2D):
	portal_exited.emit(self, body)

func _on_tunnel_entered(body: Node2D):
	tunnel_entered.emit(self, body)
	
func _on_tunnel_exit(body: Node2D):
	tunnel_exited.emit(self, body)
