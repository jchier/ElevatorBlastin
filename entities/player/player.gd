class_name Player
extends CharacterBody2D

@export var max_speed: float = 80.0
@export var jump_velocity: float = -200.0
@onready var rider_component: Area2D = $RiderComponent
@onready var visuals: Node = $Visuals
@onready var bullet_component: Node2D = $BulletComponent
@onready var state_chart: StateChart = $StateChart
@onready var standing_collision_shape: CollisionShape2D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape2D = $CrouchingCollisionShape
@onready var animation_component: Node = $AnimationComponent
@onready var fire_rate_timer: Timer = $FireRateTimer

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0
var acceleration: float = 8.0
var friction: float = 10.0
var max_gravity: float = 14.5
var min_gravity: float = 12.0
var gravity: float = 12.0
var fall_gravity = 1124
var _current_occupancy: Occupant_Component = null
var forward: bool = true
var was_on_floor: bool = false
var was_idle:bool = false
var current_speed: float
var can_shoot: bool = false

func _ready():
	rider_component.set_current_occupancy.connect(_set_current_occupancy)
	rider_component.clear_current_occupancy.connect(_clear_current_occupancy)
	animation_component.can_shoot.connect(_can_shoot)
	crouching_collision_shape.disabled = true
	current_speed = max_speed
	
func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		velocity.y = 0
		velocity.y += fall_gravity * delta
		velocity.y = clamp(velocity.y, 0, 300)
		if not was_on_floor:
			was_on_floor = true
			state_chart.send_event("grounded")
	else:
		velocity += get_gravity() * delta
		if was_on_floor:
			was_on_floor = false
			state_chart.send_event("airborne")
			
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	
	
	var x_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var velocity_weight : float = delta * (acceleration if x_input else friction)
	velocity.x = lerp(velocity.x, x_input * current_speed, velocity_weight)


	move_and_slide()


	if was_on_floor and not is_on_floor() and velocity.y > 0:
		state_chart.send_event("airborne")
	
	if velocity.x < 0 and forward == true \
		or velocity.x > 0 and forward == false:
		flip_horizontal()
	
	if _current_occupancy:	
		if Input.is_action_pressed("up"):
			_current_occupancy.set_direction(Global.UP)
		if Input.is_action_pressed("down"):
			_current_occupancy.set_direction(Global.DOWN)
			
			
	if Input.is_action_just_pressed("down"):
		state_chart.send_event("player_duck")
		
	if Input.is_action_just_released("down"):
		state_chart.send_event("player_stand")
	


		
func try_duck_fire():
	if !fire_rate_timer.is_stopped() and can_shoot:
		return
	animation_component.duck_shoot()
	fire()
	
func try_stand_fire():
	if !fire_rate_timer.is_stopped() and can_shoot:
		return
	animation_component.stand_shoot()
	fire()
	
func fire():
	bullet_component.fire()
	fire_rate_timer.start()
	#TODO: fire rate timer, effects go here

func flip_horizontal():
	bullet_component.flip_horizontal()
	visuals.scale.x *= -1.0
	forward = !forward
		
func _set_current_occupancy(occupancy: Occupant_Component):
		_current_occupancy = occupancy
		
func _clear_current_occupancy():
	_current_occupancy = null
	


func _on_stand_state_entered() -> void:
	animation_component.start("stand")



func _on_duck_state_entered() -> void:
	bullet_component.toggle_stance()
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	animation_component.play("duck")
	current_speed = 0


func _on_duck_state_exited() -> void:
	bullet_component.toggle_stance()
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	current_speed = max_speed


func _on_airborne_state_entered() -> void:
	animation_component.play("airborne")


func _on_stand_state_physics_processing(_delta: float) -> void:
	if velocity.length_squared() <= 0.555:
			animation_component.play("idle")
	else:
			animation_component.play("move")
		
	animation_component.move(signf(velocity.y))	


func _on_duck_state_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		try_duck_fire()


func _on_stand_state_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		try_stand_fire()


func _on_airborne_state_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		try_stand_fire()


func _on_to_grounded_taken() -> void:
	animation_component.start("stand")

func _can_shoot():
	can_shoot = !can_shoot
