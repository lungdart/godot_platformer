extends Actor
class_name Enemy

export var dead_zone = 50
export var sight_distance = 500
export var walk_ramp_up_time = 0.2
export var max_walk_speed = 100
export var hp = 1
export var strength = 1

var _walk_acceleration = 0.0
var _facing_right = true
var _player
var _player_cast
var _sprite_sheet
var _current_hp
var _dead = false

func _ready():
	_walk_acceleration = max_walk_speed / walk_ramp_up_time
	_player = $"../player"
	_player_cast = $"player cast"
	_sprite_sheet = $"sprite"
	_current_hp = hp
	
	# Create a sight distance long cast, and just change the angle.
	#  this prevents translating co-ordinates
	_player_cast.set_cast_to( Vector2(sight_distance, 0) )


func hit(damage):
	_current_hp -= damage
	if _current_hp < 0:
		_current_hp = 0
		die()


func die():
	queue_free()


func _cast_to_player():
	var direction = _player.global_position - _player_cast.global_position
	_player_cast.set_cast_to(direction)


func _can_see_player():
	if _player_cast.is_colliding() and _player_cast.cast_to.length() <= sight_distance:
		return true
	return false


func _walk_right(dt):
	_facing_right = true
	_sprite_sheet.flip_h = true

	if velocity.x >= 0:
		velocity.x += _walk_acceleration * dt
		velocity.x = min(velocity.x, max_walk_speed)
	else:
		velocity.x -= _walk_acceleration * dt
		velocity.x = max(velocity.x, 0)


func _walk_left(dt):
	_facing_right = false
	_sprite_sheet.flip_h = false

	if velocity.x <= 0:
		velocity.x += -_walk_acceleration * dt
		velocity.x = max(velocity.x, -max_walk_speed)
	else:
		velocity.x -= -_walk_acceleration * dt
		velocity.x = min(velocity.x, 0)


func _idle(dt):
	if velocity.x > 0:
		velocity.x -= _walk_acceleration * dt
		velocity.x = max(velocity.x, 0)
	elif velocity.x < 0:
		velocity.x += _walk_acceleration * dt
		velocity.x = min(velocity.x, 0)


func _physics_process(dt):
	_cast_to_player()
	if _can_see_player():
		var direction = _player_cast.cast_to.normalized()
		if direction.x > 0:
			_walk_right(dt)
		elif direction.x < 0:
			_walk_left(dt)
	else:
		_idle(dt)
