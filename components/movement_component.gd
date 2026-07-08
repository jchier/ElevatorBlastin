class_name MovementComponent
extends Node


signal state_chart_event(event: String)
signal set_orientation(signf: float)

@export var _character_body: CharacterBody2D

const MAX_SPEED: float = 80.0
const GRAVITY: Vector2 = Vector2(0,980)
const FALL_GRAVITY = 1124
const JUMP_VELOCITY: float = -200.0
const FRICTION: float = 10.0
const ACCELERATION: float = 8.0

var forward: bool = true
var was_on_floor: bool = false
var was_idle:bool = false
var current_speed: float
var velocity: Vector2 = Vector2.ZERO
var is_enabled: bool = true

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
			
	if Input.is_action_just_pressed("jump") and _character_body.is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var velocity_weight : float = delta * (ACCELERATION if x_input else FRICTION)
	velocity.x = lerp(velocity.x, x_input * current_speed, velocity_weight)

	if was_on_floor and not  _character_body.is_on_floor() and velocity.y > 0:
		state_chart_event.emit("airborne")
	
	if is_enabled:
		if velocity.x != 0:
			set_orientation.emit(signf(velocity.x))
		_character_body.velocity = velocity
		return
	_character_body.velocity = Vector2(0, velocity.y)
