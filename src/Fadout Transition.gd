extends CanvasLayer

signal scene_changed()

onready var _animation_player = $AnimationPlayer
onready var _black = $Control/Black

func _ready():
	_black.set_visible(false)

func change_scene(path, delay = 0.1):
	yield(get_tree().create_timer(delay), "timeout")
	_black.set_frame_color(Color(0, 0, 0, 0))
	_black.set_visible(true)
	
	_animation_player.play("fade")
	yield(_animation_player, "animation_finished")
	
	assert(get_tree().change_scene(path) == OK)

	_animation_player.play_backwards("fade")
	yield(_animation_player, "animation_finished")

	emit_signal("scene_changed")
