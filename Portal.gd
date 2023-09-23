extends Node2D

signal portal_entered(portal: Node2D, body: Node2D)
signal portal_exited(portal: Node2D, body: Node2D)
signal tunnel_entered(portal: Node2D, body: Node2D, exiting: bool)
signal tunnel_exited(portal: Node2D, body: Node2D)

@onready var exiting = false

func _ready() -> void:
	exiting = false

func _on_portal_entered(body: Node2D):
	portal_entered.emit(self, body)
	
func _on_portal_exit(body: Node2D):
	exiting = true
	portal_exited.emit(self, body)

func _on_tunnel_entered(body: Node2D):
	print(exiting)
	tunnel_entered.emit(self, body, exiting)
	
func _on_tunnel_exit(body: Node2D):
	exiting = false
	tunnel_exited.emit(self, body)
