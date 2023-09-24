extends Node2D

var save_state: SaveState

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("BackgroundAnimation").play("default")
	load_timer()
	show_timer()

func load_timer():
	if ResourceLoader.exists("res://timer.tres"):
		save_state = ResourceLoader.load("res://timer.tres")
		print(save_state)

func show_timer():
	if save_state != null:
		$Label2.text += " %.2fs" % save_state.timer
		$Label2.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://GameScene.tscn")
