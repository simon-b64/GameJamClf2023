extends Node2D

# Portal Logic
var portals = {}
var current_portal: Node2D
var next_portal: Node2D
var current_tunnel: Area2D

# Player
@onready var player := $Player
var player_can_teleport = true

# DEBUG
@onready var slider := $Fade/HSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	register_portals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_tunnel == null:
		return
	handle_fog()
	
func handle_fog():
	var ds = min(1, max(0, absf(distance(player, current_tunnel))))
	var rev = max(0,0.6 - ds*1.3)
	var sc = 4 + (60 * rev)
	$Player/Fog.scale = Vector2(sc,sc)
	var camfactor = 1 - ds
	if camfactor < 0.01:
		$Player/Camera2D.position_smoothing_enabled = false
	elif camfactor < 1:
		$Player/Fog.visible = true
		$Player/Camera2D.position_smoothing_enabled = true
	else:
		$Player/Fog.visible = false
	
	$Player/Camera2D.position_smoothing_speed = 5 * 1/(camfactor+0.1)
	$Player/Camera2D.drag_top_margin = 0.2 * camfactor
	$Player/Camera2D.drag_bottom_margin = 0.2 * camfactor
	$Player/Camera2D.drag_left_margin = 0.2 * camfactor
	$Player/Camera2D.drag_right_margin = 0.2 * camfactor
	
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

func connect_to_portal(portal: Node2D):
	portal.portal_entered.connect(_on_portal_entered)
	portal.portal_exited.connect(_on_portal_exited)
	portal.tunnel_entered.connect(_on_tunnel_entered)
	portal.tunnel_exited.connect(_on_tunnel_exited)

func _on_portal_entered(portal: Node2D, body: Node2D):
	if body != player || !player_can_teleport:
		return
	player_can_teleport = false
	current_portal = portal
	next_portal = portals[portal]
	print(next_portal)
	teleport_player()

func _on_portal_exited(portal: Node2D, body: Node2D):
	if body != player:
		return
	current_portal = null
	next_portal = null
	player_can_teleport = true

func teleport_player():
	player.global_position = next_portal.get_node("Portal").global_position

func _on_tunnel_entered(portal: Node2D, body: Node2D, exiting: bool):
	if body != player:
		return
	current_tunnel = portal.get_node("Tunnel")
	print(current_tunnel)

func _on_tunnel_exited(portal: Node2D, body: Node2D):
	print("on_tunnel_exited")
	if body != player:
		return
	current_tunnel = null
	
func distance(player: Node2D, tunnel: Node2D):
	var shape = ((tunnel as Area2D).get_node("CollisionShape2D") as CollisionShape2D)
	var rect = (shape.shape as RectangleShape2D)
	var size = tunnel.get_global_transform().basis_xform(rect.size)
	
	var rpos = player.get_global_transform().get_origin() - tunnel.get_global_transform().get_origin()
	
	var apos = max(-1,min(0,(rpos / abs(size)).x - 0.5 ))
	if sign(size.x) > 0:
		return abs(apos) - 1
	else :
		return abs(apos)

