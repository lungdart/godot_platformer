extends Node2D

onready var transition = $"/root/FadeTransition"
export var start_scene = "res://src/levels/test level.tscn"
var selected = null


func _on_Start_button_up():
	transition.change_scene(start_scene)


func _on_Quit_button_up():
	get_tree().quit()


func _ready():
	select($Control/Start)

func select(button):
	selected = button
	button.grab_focus()


func _input(event):
	if selected == $Control/Start:
		if event.is_action("down") and event.is_pressed():
			select($Control/Quit)
		elif event.is_action("confirm") and event.is_pressed():
			_on_Start_button_up()

	elif selected == $Control/Quit:
		if event.is_action("up") and event.is_pressed():
			select($Control/Start)
		elif event.is_action("confirm") and event.is_pressed():
			_on_Quit_button_up()
		
