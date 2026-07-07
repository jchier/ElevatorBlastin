class_name MovementComponent
extends Node

signal flip_horizontal
signal state_chart_event(event: String)

var max_speed: float = 80.0
var jump_velocity: float = -200.0


var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0
var acceleration: float = 8.0
var friction: float = 10.0
var max_gravity: float = 14.5
var min_gravity: float = 12.0
var gravity: Vector2 = Vector2(0,980)
var fall_gravity = 1124
var forward: bool = true
var was_on_floor: bool = false
var was_idle:bool = false
var current_speed: float

var is_on_floor: bool
var velocity: Vector2 = Vector2.ZERO
func ready():
	pass
	
func toggle_on_floor(on_floor: bool):
	current_speed = max_speed
	is_on_floor = on_floor

func generate_velocity(delta: float) -> Vector2:
	
	if is_on_floor:
		velocity.y = 0
		velocity.y += fall_gravity * delta
		velocity.y = clamp(velocity.y, 0, 300)
		if not was_on_floor:
			was_on_floor = true
			state_chart_event.emit("grounded")
	else:
		velocity += gravity * delta
		if was_on_floor:
			was_on_floor = false
			state_chart_event.emit("airborne")
			
	if Input.is_action_just_pressed("jump") and is_on_floor:
		velocity.y = jump_velocity
		
	
	var x_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var velocity_weight : float = delta * (acceleration if x_input else friction)
	velocity.x = lerp(velocity.x, x_input * current_speed, velocity_weight)

	if was_on_floor and not is_on_floor and velocity.y > 0:
		state_chart_event.emit("airborne")
	
	if velocity.x < 0 and forward == true \
		or velocity.x > 0 and forward == false:
		flip_horizontal.emit()
		forward = !forward


	return velocity
