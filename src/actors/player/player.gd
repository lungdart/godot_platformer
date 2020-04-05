extends Actor
class_name Player

### Tunable parameters
export var max_walk_speed = 500.0
export var walk_ramp_up_time = 0.5
export var walk_ramp_down_time = 0.2
export var turn_ramp_down_time = 0.1
export var jump_height = 250.0
export var strength = 1
export var hp = 3

### Derived parameters
var _walk_acceleration = 0.0
var _walk_deceleration = 0.0
var _turn_deceleration = 0.0
var _jump_initialvelocity = 0.0

var _animation_state
var _sprite_sheet
var _damage_cast

var _idle_timer = 0.0
var _facing_right = true
var _jumping = false
var _falling = true
var _current_hp = 0


func _ready():
	### Setting these outside of ready scope causes the exported tuned values to not take effect
	_walk_acceleration = max_walk_speed / walk_ramp_up_time
	_walk_deceleration = -max_walk_speed / walk_ramp_down_time
	_turn_deceleration = -max_walk_speed / turn_ramp_down_time
	_jump_initialvelocity = sqrt(2 * gravity * jump_height)
	
	_animation_state = $"Animation States".get("parameters/playback")
	_sprite_sheet = $"sprite sheet"
	_damage_cast = $"DamageCast"
	
	_current_hp = hp
	

### Got hit by an enemy
func hit(value):
	print("Got damaged: ", value)


### Horizontal movement
func walk_right(dt):
	_facing_right = true
	_sprite_sheet.flip_h = false
	_idle_timer = 0.0

	if not _jumping or not _falling:
		_animation_state.travel("walk")

	if velocity.x >= 0:
		velocity.x += _walk_acceleration * dt
		velocity.x = min(velocity.x, max_walk_speed)
	else:
		velocity.x += -_turn_deceleration * dt
		velocity.x = min(velocity.x, 0)


func _walk_left(dt):
	_facing_right = false
	_sprite_sheet.flip_h = true
	_idle_timer = 0.0

	if not _jumping or not _falling:
		_animation_state.travel("walk")

	if velocity.x <= 0:
		velocity.x += -_walk_acceleration * dt
		velocity.x = max(velocity.x, -max_walk_speed)
	else:
		velocity.x += _turn_deceleration * dt
		velocity.x = max(velocity.x, 0)


func _idle(dt):
	if not _jumping:
		_idle_timer += dt
		if _idle_timer > 1.0:
			_animation_state.travel("idle2")
		else:
			_animation_state.travel("idle")

	if velocity.x > 0:
		velocity.x += _walk_deceleration * dt
		velocity.x = max(velocity.x, 0)
	elif velocity.x < 0:
		velocity.x += -_walk_deceleration * dt
		velocity.x = min(velocity.x, 0)


### Vertical movement
func _jump(dt, strength):
	_jumping = true
	_animation_state.travel("jump")
	velocity.y = -_jump_initialvelocity * strength
	

func _land(dt):
	_jumping = false
	_animation_state.travel("idle")


func _fall(dt):
	_jumping = false
	_falling = true
	_animation_state.travel("fall")


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
		_idle(dt)

	# Handle vertical movement
	var jump_strength = Input.get_action_strength("jump")
	if jump_strength and is_on_floor():
		_jump(dt, jump_strength)
	elif _jumping and is_on_floor():
		_land(dt)
	elif not _jumping and not is_on_floor():
		_fall(dt)


	# Handle squishing enemies
	if _damage_cast.is_colliding():
		var object = _damage_cast.get_collider()
		object.hit(strength)
	
	
