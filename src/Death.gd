extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		node.set_visible(false)


func activate(kill_count):
	var kills = $"Total Kills"
	kills.clear()
	kills.add_text("Final kill count: " + str(kill_count))

	for node in get_children():
		node.set_visible(true)
		
	var start_menu = "res://src/Start Menu.tscn"
	$"/root/FadeTransition".change_scene(start_menu, 1.0)
