extends Actor
class_name Player

### Tunable parameters
export var max_walk_speed = 500.0
export var walk_ramp_up_time = 0.5
export var walk_ramp_down_time = 0.2
export var turn_ramp_down_time = 0.1
export var jump_height = 250.0

### Derived parameters
var _walk_acceleration = 0.0
var _walk_deceleration = 0.0
var _turn_deceleration = 0.0
var _jump_initialvelocity = 0.0
var _facing_right = true


func _ready():
	### Setting these outside of ready scope causes the exported tuned values to not take effect
	_walk_acceleration = max_walk_speed / walk_ramp_up_time
	_walk_deceleration = -max_walk_speed / walk_ramp_down_time
	_turn_deceleration = -max_walk_speed / turn_ramp_down_time
	_jump_initialvelocity = sqrt(2 * gravity * jump_height)
	

### Horizontal movement
func walk_right(dt):
	_facing_right = true
	if velocity.x >= 0:
		velocity.x += _walk_acceleration * dt
		velocity.x = min(velocity.x, max_walk_speed)
	else:
		velocity.x += -_turn_deceleration * dt
		velocity.x = min(velocity.x, 0)


func _walk_left(dt):
	_facing_right = false
	if velocity.x <= 0:
		velocity.x += -_walk_acceleration * dt
		velocity.x = max(velocity.x, -max_walk_speed)
	else:
		velocity.x += _turn_deceleration * dt
		velocity.x = max(velocity.x, 0)


func _stand_still(dt):
	if velocity.x > 0:
		velocity.x += _walk_deceleration * dt
		velocity.x = max(velocity.x, 0)
	elif velocity.x < 0:
		velocity.x += -_walk_deceleration * dt
		velocity.x = min(velocity.x, 0)


### Vertical movement
func _jump(dt, strength):
	if is_on_floor():
		velocity.y = -_jump_initialvelocity * strength


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
		walk_right(dt)
	else:
		_stand_still(dt)

	# Handle vertical movement
	var jump_strength = Input.get_action_strength("jump")
	if jump_strength:
		_jump(dt, jump_strength)
