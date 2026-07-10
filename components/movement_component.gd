class_name MovementComponent
extends Node


signal state_chart_event(event: String)
signal set_orientation(signf: float)

@export var _character_body: CharacterBody2D

const MAX_SPEED: float = 80.0
const GRAVITY: Vector2 = Vector2(0,980)
const FALL_GRAVITY = 1124
const JUMP_VELOCITY: float = -250.0
const FRICTION: float = 10.0
const ACCELERATION: float = 8.0

var forward: bool = true
var was_on_floor: bool = false
var was_idle:bool = false
var current_speed: float
var velocity: Vector2 = Vector2.ZERO
var disabled: bool = false
var last_orientation = 1
var _jump: bool = false

func _ready():
	current_speed = MAX_SPEED

func toggle_movement():
	if current_speed == 0:
		current_speed = MAX_SPEED
	else:
		current_speed = 0

func generate_velocity(delta: float, x_input: float):
	
	if _character_body.is_on_floor():
		velocity.y = 0
		velocity.y += FALL_GRAVITY * delta
		velocity.y = clamp(velocity.y, 0, 300)
		if not was_on_floor:
			was_on_floor = true
			state_chart_event.emit("grounded")
	else:
		velocity += GRAVITY * delta
		if was_on_floor:
			was_on_floor = false
			state_chart_event.emit("airborne")
			
	if _jump:
		velocity.y = JUMP_VELOCITY
		_jump = false
		
	var velocity_weight : float = delta * (ACCELERATION if x_input else FRICTION)
	velocity.x = lerp(velocity.x, x_input * current_speed, velocity_weight)

	if was_on_floor and not  _character_body.is_on_floor() and velocity.y > 0:
		state_chart_event.emit("airborne")
	
	if !disabled:
		if velocity.x != 0:
			var orientation = signf(velocity.x)
			if orientation != last_orientation:
				last_orientation = orientation
				set_orientation.emit(orientation)
		_character_body.velocity = velocity
		return
	_character_body.velocity = Vector2(0, velocity.y)
	
func jump():
	if _character_body.is_on_floor():
		_jump = true
