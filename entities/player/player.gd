class_name Player
extends CharacterBody2D

@export var max_speed: float = 80.0
@export var jump_velocity: float = -200.0
@onready var camera: Camera2D = $Camera2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var left_head_nudge_2: RayCast2D = $Left_HeadNudge2
@onready var right_head_nudge: RayCast2D = $Right_HeadNudge
@onready var right_head_nudge_2: RayCast2D = $Right_HeadNudge2
@onready var right_ledge_hop: RayCast2D = $Right_LedgeHop
@onready var right_ledge_hop_2: RayCast2D = $Right_LedgeHop2
@onready var left_ledge_hop: RayCast2D = $Left_LedgeHop
@onready var left_ledge_hop_2: RayCast2D = $Left_LedgeHop2

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0

var acceleration: float = 8.0
var friction: float = 10.0
var coyote_time_activated: bool = false
var max_gravity: float = 14.5
var min_gravity: float = 12.0
var gravity: float = 12.0
var fall_gravity = 1124


func ready


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y += fall_gravity * delta
		velocity.y = clamp(velocity.y, 0, 300)
		
			
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	



	var x_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var velocity_weight : float = delta * (acceleration if x_input else friction)
	velocity.x = lerp(velocity.x, x_input * max_speed, velocity_weight)

	var was_on_floor = is_on_floor()

	move_and_slide()

	if was_on_floor and not is_on_floor() and velocity.y > 0:
		coyote_timer.start()
