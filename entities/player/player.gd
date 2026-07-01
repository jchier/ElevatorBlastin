class_name Player
extends CharacterBody2D



@export var max_speed: float = 80.0
@export var jump_velocity: float = -200.0
@onready var camera: Camera2D = $Camera2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var rider_component: Area2D = $RiderComponent
@onready var visuals: Node = $Visuals
@onready var animation_player_torso: AnimationPlayer = $AnimationPlayerTorso
@onready var animation_player_legs: AnimationPlayer = $AnimationPlayerLegs
@onready var bullet_marker_2d: Marker2D = $BulletMarker2D
@onready var state_chart: StateChart = $StateChart
@onready var standing_collision_shape: CollisionShape2D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape2D = $CrouchingCollisionShape
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
var bullet_scene: PackedScene = preload("uid://rnaqg1ycr0e1")

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


var _current_elevator: Elevator = null
var _current_occupancy: Occupant_Component = null
var forward: bool = true

func _ready():
	rider_component.set_current_occupancy.connect(_set_current_occupancy)
	rider_component.clear_current_occupancy.connect(_clear_current_occupancy)
	crouching_collision_shape.disabled = true
	
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
	
	if velocity.x < 0 and forward == true \
		or velocity.x > 0 and forward == false:
		flip_horizontal()
	
	if _current_occupancy:	
		if Input.is_action_pressed("up"):
			_current_occupancy.set_direction(Global.UP)
		if Input.is_action_pressed("down"):
			_current_occupancy.set_direction(Global.DOWN)
			
	if Input.is_action_pressed("left") and\
	Input.is_action_pressed("right"):
			state_chart.send_event("player_stand")
			velocity.x = 0
			return
			
	if Input.is_action_just_pressed("down"):
		state_chart.send_event("player_duck")
			
	if Input.is_action_just_released("left")\
	or Input.is_action_just_released("right"):
		state_chart.send_event("player_stand")
		
	if Input.is_action_just_released("down"):
		state_chart.send_event("player_stand")
		
	if Input.is_action_just_pressed("shoot"):
		try_fire()
		
	#if velocity.x < -20.0 or velocity.x > 20.0:
	if Input.is_action_pressed("left")\
	or Input.is_action_pressed("right"):
		state_chart.send_event("player_walking")

	

#func play_walking_animation():
#	if animation_player_legs.is_playing():
#		return
#	animation_player_legs.play("walk")

#func stop_walking_animation():
#	if animation_player_legs.is_playing():
#		animation_player_legs.stop()

func try_fire():
	if animation_player_torso.is_playing():
		animation_player_torso.stop()
	animation_player_torso.play("shoot")
	
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.global_position = bullet_marker_2d.global_position
	bullet.start(bullet_marker_2d.global_rotation)
	get_parent().add_child(bullet, true)
	#TODO: fire rate timer, effects go here

func flip_horizontal():
	visuals.scale.x *= -1.0
	bullet_marker_2d.position.x *= -1.0
	bullet_marker_2d.rotation *= -1.0
	forward = !forward
		
func _set_current_occupancy(occupancy: Occupant_Component):
		_current_occupancy = occupancy
		
func _clear_current_occupancy():
	_current_occupancy = null
	


func _on_stand_state_entered() -> void:
	#await animation_player_legs.animation_finished
	#animation_player_legs.play("idle")
	animation_state_machine.travel("idle")



func _on_duck_state_entered() -> void:
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	print(animation_player_legs.current_animation)
	#animation_player_legs.stop()
	#animation_player_legs.play("duck")
	animation_state_machine.travel("duck")




func _on_walking_state_entered() -> void:
	animation_state_machine.travel("move")



func _on_to_stand_taken() -> void:
	animation_player_legs.stop()


func _on_duck_state_exited() -> void:
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	#animation_player_legs.stop()
	#animation_player_legs.play_backwards("duck")
	#animation_state_machine.travel("stand")
