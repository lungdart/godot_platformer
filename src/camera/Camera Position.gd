extends Position2D

export var distance = 300
onready var player = get_parent()

func _physics_process(dt):
	_update_camera_pivot()

func _update_camera_pivot():
	
	if player._facing_right:
		set_position( Vector2(distance, 0) )
	else:
		set_position( Vector2(-distance, 0) )
