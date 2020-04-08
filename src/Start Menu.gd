extends Node2D

onready var transition = $"/root/FadeTransition"
export var level = "res://src/levels/test level.tscn"

func _on_Start_button_up():
	transition.change_scene(level)

func _on_Quit_button_up():
	get_tree().quit()
