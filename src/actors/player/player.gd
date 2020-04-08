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
export var idle_time = 5.0
export var iframes_time = 1.5

# Private paramters
var _facing_right = true
var _jumping = false
var _falling = true
var _current_hp = 0
var _invincible = false
var _idle_counter = 0.0
var _iframes_counter = 0.0
var _flash_rate = 0.05

### Derived parameters
onready var _walk_acceleration = max_walk_speed / walk_ramp_up_time
onready var _walk_deceleration = -max_walk_speed / walk_ramp_down_time
onready var _turn_deceleration = -max_walk_speed / turn_ramp_down_time
onready var _jump_initialvelocity = sqrt(2 * gravity * jump_height)

# External resources
onready var _animation_state = $"Animation States".get("parameters/playback")
onready var _sprite_sheet = $"sprite sheet"
onready var _damage_cast = $"DamageCast"
onready var _life_meter = $"../HUD Canvas/HUD/Life"
onready var _death_layer = $"Camera Position/Death Layer"
onready var _kill_counter = $"../HUD Canvas/HUD/Kills"
onready var _camera = $"Camera Position"


func _ready():
	### Setting these outside of ready scope causes the exported tuned values to not take effect
	
	$"hitbox".connect("area_entered", self, "_on_hitbox_collision")
	
	_current_hp = hp


func _take_damage(strength):
	_current_hp -= strength
	if _current_hp <= 0:
		_current_hp = 0
		
	_set_life(_current_hp)

	if _current_hp == 0:
		_die()
	else:
		_invincible = true
		_animation_state.travel("hurt")


func _die():
	_animation_state.travel("death")
	print(_kill_counter)
	var kills = _kill_counter.kill_counter
	_death_layer.activate(kills)


func _set_life(count):
	var heart_0 = false
	var heart_1 = false
	var heart_2 = false
	if _current_hp >= 1:
		heart_0  = true
	if _current_hp >= 2:
		heart_1 = true
	if _current_hp >= 3:
		heart_2 = true
		
	_life_meter.get_node("heart_full_0").set_visible(heart_0)
	_life_meter.get_node("heart_full_1").set_visible(heart_1)
	_life_meter.get_node("heart_full_2").set_visible(heart_2)

### Horizontal movement
func walk_right(dt):
	_facing_right = true
	_sprite_sheet.flip_h = false
	_idle_counter = 0.0

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
	_idle_counter = 0.0

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
		_idle_counter += dt
		if _idle_counter > idle_time:
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


func _flash(counter, reset=false):
	if reset:
		_sprite_sheet.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
		return

	# Change opacity fully every 100ms
	var frame = fmod(counter, _flash_rate)
	var alpha = range_lerp(frame, 0, _flash_rate, 0.0, 1.0)
	_sprite_sheet.set_modulate(Color(1.0, 1.0, 1.0, alpha))


func _on_hitbox_collision(other_area):
	if other_area.collision_layer == 1 and not _invincible:
		var enemy = other_area.get_parent()
		_take_damage(enemy.strength)
		

### Update the physics of the actor by dt
func _physics_process(dt):
	if _current_hp <= 0:
		return

	# Handle iframes
	if _invincible:
		_iframes_counter += dt
		_flash(_iframes_counter)
		if _iframes_counter > iframes_time:
			_invincible = false
			_iframes_counter = 0.0
			_flash(0, true)


	# Handle horinzontal movement
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
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
