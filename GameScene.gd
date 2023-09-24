extends Node2D

# Common
var children = []

# Portal Logic
var portals = {}
var current_portal: Node2D
var next_portal: Node2D
var current_tunnel: Area2D

# Player
@onready var player := $Player
var player_can_teleport = true
var amount_of_keys := 0

# DEBUG
@onready var slider := $Fade/HSlider

# Timer
var timer := 0.0
@onready var timer_label := $CanvasLayer/TimerLabel

# YEEEAAAAHHH BOOOOIIIIII
@onready var radio := $Scene03/Radio
@onready var musicPlayer := $MainMusicPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	children = get_all_children(self)
	register_portals()
	register_keys()
	register_locked_entries()
	register_text_triggers()
	connect_to_radio()

func get_all_children(node: Node, children:=[]):
	children.push_back(node)
	for child in node.get_children():
		if child in children:
			continue
		children = get_all_children(child, children)
	return children

func register_portals():
	var portal_array = children.filter(func(child): return child.scene_file_path == "res://Portal.tscn")
	var portal_assignment = {}
	for portal in portal_array:
		connect_to_portal(portal)
		if portal.portal_channel in portal_assignment:
			portal_assignment[portal.portal_channel].push_back(portal)
		else:
			portal_assignment[portal.portal_channel] = [portal]
	for assignment in portal_assignment.values():
		if len(assignment) != 2:
			continue
		portals[assignment[0]] = assignment[1]
		portals[assignment[1]] = assignment[0]

func connect_to_portal(portal: Node2D):
	portal.portal_entered.connect(_on_portal_entered)
	portal.portal_exited.connect(_on_portal_exited)
	portal.tunnel_entered.connect(_on_tunnel_entered)
	portal.tunnel_exited.connect(_on_tunnel_exited)

func register_keys():
	var key_array = children.filter(func(child): return child.scene_file_path == "res://Key.tscn")
	for key in key_array:
		connect_to_key(key)

func connect_to_key(key: Area2D):
	key.key_entered.connect(_on_key_entered)

func register_locked_entries():
	var locked_entries = children.filter(func(child): return child.scene_file_path == "res://LockedEntry.tscn")
	for locked_entry in locked_entries:
		connect_to_locked_entry(locked_entry)

func connect_to_locked_entry(locked_entry: StaticBody2D):
	locked_entry.locked_entry_entered.connect(_on_locked_entry_entered)

func register_text_triggers():
	var text_triggers = children.filter(func(child): return child.scene_file_path == "res://TextTrigger.tscn")
	for text_trigger in text_triggers:
		connect_to_text_trigger(text_trigger)

func connect_to_text_trigger(text_trigger):
	text_trigger.text_trigger_entered.connect(_on_text_trigger)

func connect_to_radio():
	radio.radio_entered.connect(_on_radio_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_volume()
	handle_timer(delta)
	if current_tunnel == null:
		return
	handle_fog()
	
func handle_fog():
	var ds = min(1, max(0, absf(distance(player, current_tunnel))))
	var rev = max(0,0.6 - ds*1.3)
	var sc = 2 + (60 * rev)
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

func handle_volume():
	var distance = player.get_global_transform().get_origin().distance_squared_to(radio.get_global_transform().get_origin())
	var clamped_distance = min(1, max(0, log(distance)/50))
	musicPlayer.volume_db = 2 * (1 - clamped_distance)

func handle_timer(delta: float):
	timer += delta
	timer_label.text = "%.2f" % timer

# PORTAL LOGIC

func _on_portal_entered(portal: Node2D, body: Node2D):
	if body != player || !player_can_teleport:
		return
	player_can_teleport = false
	current_portal = portal
	next_portal = portals[portal]
	teleport_player()

func _on_portal_exited(portal: Node2D, body: Node2D):
	if body != player:
		return
	current_portal = null
	next_portal = null
	player_can_teleport = true

func teleport_player():
	player.global_position = next_portal.get_node("Portal").global_position

func _on_tunnel_entered(portal: Node2D, body: Node2D):
	if body != player:
		return
	current_tunnel = portal.get_node("Tunnel")

func _on_tunnel_exited(portal: Node2D, body: Node2D):
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


# KEY LOGIC

func _on_key_entered(key: Area2D, body: Node2D):
	if body != player:
		return
	amount_of_keys += 1
	key.queue_free()


# LOCKED_ENTRY LOGIC

func _on_locked_entry_entered(locked_entry: StaticBody2D, body: Node2D):
	if body != player || amount_of_keys <= 0:
		return
	amount_of_keys -= 1
	locked_entry.queue_free()


# TEXT TRIGGER LOGIC

func _on_text_trigger(text_trigger: Area2D, body: Node2D):
	if body != player:
		return
	if text_trigger.show_text:
		player.display_text(text_trigger.text)
	else:
		player.hide_thoughts()


# RADIO LOGIC

func _on_radio_entered(radio, body):
	if body != player:
		return
	var save_state = SaveState.new()
	save_state.timer = timer
	ResourceSaver.save(save_state, "res://timer.tres")
	get_tree().change_scene_to_file("res://MainMenu.tscn")
