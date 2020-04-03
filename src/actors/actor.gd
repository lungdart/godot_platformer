extends KinematicBody2D
class_name Actor

### Tunable parameters
export var jump_height = 160.0
export var gravity = 500.0
export var max_fall_speed = 1000.0

export var max_walk_speed = 500.0
export var walk_ramp_up_time = 0.5
export var walk_ramp_down_time = 0.2
export var turn_ramp_down_time = 0.1

### Derived parameters
var _walk_acceleration = 0.0
var _walk_deceleration = 0.0
var _turn_deceleration = 0.0
var _jump_initial_velocity = 0.0

### State keeping
var _velocity = Vector2.ZERO

func _ready():
	### Setting these outside of ready scope causes the exported tuned values to not take effect
	_walk_acceleration = max_walk_speed / walk_ramp_up_time
	_walk_deceleration = -max_walk_speed / walk_ramp_down_time
	_turn_deceleration = -max_walk_speed / turn_ramp_down_time
	_jump_initial_velocity = sqrt(2 * gravity * jump_height)
	

### Horizontal movement
func _walk_right(dt):
	if _velocity.x >= 0:
		_velocity.x += _walk_acceleration * dt
		_velocity.x = min(_velocity.x, max_walk_speed)
	else:
		_velocity.x += -_turn_deceleration * dt
		_velocity.x = min(_velocity.x, 0)


func _walk_left(dt):
	if _velocity.x <= 0:
		_velocity.x += -_walk_acceleration * dt
		_velocity.x = max(_velocity.x, -max_walk_speed)
	else:
		_velocity.x += _turn_deceleration * dt
		_velocity.x = max(_velocity.x, 0)


func _stand_still(dt):
	if _velocity.x > 0:
		_velocity.x += _walk_deceleration * dt
		_velocity.x = max(_velocity.x, 0)
	elif _velocity.x < 0:
		_velocity.x += -_walk_deceleration * dt
		_velocity.x = min(_velocity.x, 0)


### Vertical movement
func _jump(dt, strength):
	if is_on_floor():
		_velocity.y = -_jump_initial_velocity * strength


func _fall(dt):
	_velocity.y += gravity * dt
	if _velocity.y > max_fall_speed:
		_velocity.y = max_fall_speed


### Update the physics of the actor by dt
func _physics_process(dt):
	# Handle horinzontal movement
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	if left and right:
		left = false
		right = false

	if left:
		_walk_left(dt)
	elif right:
		_walk_right(dt)
	else:
		_stand_still(dt)

	# Handle vertical movement
	var jump_strength = Input.get_action_strength("jump")
	if jump_strength:
		_jump(dt, jump_strength)
	_fall(dt)
	
	# Move actor
	_velocity = move_and_slide(_velocity, Vector2.UP)
