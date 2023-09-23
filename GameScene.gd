extends Node2D

var portals = {}
var current_portal: Area2D
var next_portal: Area2D
var previous_next_portal: Area2D
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	register_portals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# Portal Service
# Refactor with GAMEJAMDEV-1234
func register_portals():
	print(self)
	var children = get_all_children(self)
	var portal_array = children.filter(func(child): return child.scene_file_path == "res://Portal.tscn")
	var portal_assignment = {}
	for portal in portal_array:
		connect_to_portal(portal)
		if portal.get_name() in portal_assignment:
			portal_assignment[portal.get_name()].push_back(portal)
		else:
			portal_assignment[portal.get_name()] = [portal]
	for assignment in portal_assignment.values():
		portals[assignment[0]] = assignment[1]
		portals[assignment[1]] = assignment[0]

func get_all_children(node: Node, children:=[]):
	children.push_back(node)
	for child in node.get_children():
		if child in children:
			continue
		children = get_all_children(child, children)
	return children

func connect_to_portal(portal: Area2D):
	portal.portal_entered.connect(_on_portal_entered)
	portal.portal_exited.connect(_on_portal_exited)

func _on_portal_entered(portal: Area2D):
	current_portal = portal
	next_portal = portals[portal]
	print(next_portal)
	teleport_player()

func _on_portal_exited(portal: Area2D):
	current_portal = null
	next_portal = null

func teleport_player():
	player.global_position = next_portal.global_position
