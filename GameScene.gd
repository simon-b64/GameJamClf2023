extends Node2D

# Portal Logic
var portals = {}
var current_portal: Node2D
var next_portal: Node2D
var current_tunnel: Area2D

# Player
@onready var player := $Player
var player_can_teleport = true

# Fade
@onready var fade_texture_block := $Fade/TextureRect
var fade_gradient := Gradient.new()
var fade_gradient_texture := GradientTexture2D.new()

# DEBUG
@onready var slider := $Fade/HSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	register_portals()
	fade_gradient.offsets = [0.0, 0.0]
	fade_gradient.colors = [Color.BLACK, Color.TRANSPARENT]
	fade_gradient_texture.gradient = fade_gradient
	fade_texture_block.texture = fade_gradient_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_tunnel != null:
		set_gradient(distance(player, current_tunnel))
	#set_gradient(slider.value)
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
	player.global_position = next_portal.global_position

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
	
func set_gradient(value: float):
	var result = min(1, max(0, absf(value)))*1.3
	if value >= 0:
		fade_gradient.colors = [Color.BLACK, Color.TRANSPARENT]
		fade_gradient.offsets = [result - 0.3, result]
	else:
		fade_gradient.colors = [Color.TRANSPARENT, Color.BLACK]
		fade_gradient.offsets = [1.3 - result - 0.3, 1.3 - result]

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

