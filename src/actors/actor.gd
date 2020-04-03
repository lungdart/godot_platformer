extends KinematicBody2D
class_name Actor

export var gravity = 800
export var max_fall_speed = 5400

var velocity = Vector2.ZERO

func fall(dt):
	velocity.y += gravity * dt
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

func _physics_process(dt):
	fall(dt)
	velocity = move_and_slide(velocity, Vector2.UP)
