class_name MovementComponent
extends Node


signal state_chart_event(event: String)
signal set_orientation(signf: float)
signal jump_good

@export var _character_body: CharacterBody2D
@onready var coyote_timer: Timer = $CoyoteTimer

@export var max_speed: float = 80.0
const GRAVITY: Vector2 = Vector2(0,980)
const FALL_GRAVITY = 1124
const JUMP_VELOCITY: float = -250.0
const FRICTION: float = 10.0
const ACCELERATION: float = 8.0
const MAX_FALL_SPEED: float = 600.0
var forward: bool = true
var was_on_floor: bool = false		
var was_idle:bool = false
var current_speed: float
var velocity: Vector2 = Vector2.ZERO
var disabled: bool:
	set(value):
		disabled = value
var die_on_land: bool = false		
var orientation: float:
	set(value):
		orientation = value
		if value != last_orientation:
			last_orientation = value
			set_orientation.emit(value)
var last_orientation = 1
var _jump: bool = false
var _can_coyote_jump = true:
	set(value):
		_can_coyote_jump = value
		print("can coyote jump: ", value)
		
var orientation_lock: bool = false

func _ready():
	current_speed = max_speed

func toggle_movement():
	if current_speed == 0:
		current_speed = max_speed
	else:
		current_speed = 0

func generate_velocity(delta: float, x_input: float):
	
	if _character_body.velocity.y > MAX_FALL_SPEED and !disabled:
		#print(_character_body.velocity.y)
		die_on_land = true
	

	
	if _character_body.is_on_floor():
		_character_body.velocity.y = 0
		_character_body.velocity.y += FALL_GRAVITY * delta
		_character_body.velocity.y = clamp(_character_body.velocity.y, 0, 300)
		if not was_on_floor:
			if die_on_land:
				state_chart_event.emit("dead")
			was_on_floor = true
			state_chart_event.emit("grounded")
			coyote_timer.stop()
			_can_coyote_jump = true
	else:
		_character_body.velocity += GRAVITY * delta
		if was_on_floor:
			was_on_floor = false
			state_chart_event.emit("airborne")
			coyote_timer.start()

			
	if _jump:
		_character_body.velocity.y = JUMP_VELOCITY
		_jump = false

		
	var velocity_weight : float = delta * (ACCELERATION if x_input else FRICTION)
	_character_body.velocity.x = lerp(_character_body.velocity.x, x_input * current_speed, velocity_weight)

	if was_on_floor and not  _character_body.is_on_floor() and _character_body.velocity.y > 0:
		state_chart_event.emit("airborne")
	
	if !disabled:
		if !is_zero_approx(_character_body.velocity.x) and !orientation_lock:
			orientation = signf(_character_body.velocity.x)
		return
	_character_body.velocity = Vector2(0, velocity.y)

func jump():
	if _can_coyote_jump and disabled == false:
		_can_coyote_jump = false
		jump_good.emit()
		_jump = true


func _on_coyote_timer_timeout() -> void:
	_can_coyote_jump = false
