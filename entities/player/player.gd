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
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var floor_detector_component: FloorDetectorComponent = $FloorDetectorComponent

signal died

var _current_occupancy: Occupant_Component = null
var can_shoot: bool = false

func _ready():
	rider_component.set_current_occupancy.connect(_set_current_occupancy)
	rider_component.clear_current_occupancy.connect(_clear_current_occupancy)
	movement_component.state_chart_event.connect(_state_chart_event)
	movement_component.set_orientation.connect(set_orientation)
	animation_component.can_shoot.connect(_can_shoot)
	health_component.died.connect(_on_died)
	crouching_collision_shape.disabled = true

	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("jump"):
		movement_component.jump()	
		
	var x_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	movement_component.generate_velocity(delta, x_input)

	move_and_slide()

	if _current_occupancy:	
		if Input.is_action_pressed("up"):
			_current_occupancy.set_direction(Global.UP)
		if Input.is_action_pressed("down"):
			_current_occupancy.set_direction(Global.DOWN)
			
			
	if Input.is_action_pressed("down"):
		state_chart.send_event("duck")
		
	if Input.is_action_just_released("down"):
		state_chart.send_event("stand")


		
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

func set_orientation(sign_f: float):
	bullet_component.flip_horizontal(sign_f)
	visuals.scale.x = sign_f
		
func _set_current_occupancy(occupancy: Occupant_Component):
		_current_occupancy = occupancy
		
func _clear_current_occupancy():
	_current_occupancy = null
	


func _on_stand_state_entered() -> void:
	animation_component.start("stand")



func _on_duck_state_entered() -> void:
	bullet_component.toggle_stance()
	hurtbox_component.toggle_stance()
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	animation_component.play("duck")
	movement_component.toggle_movement()


func _on_duck_state_exited() -> void:
	bullet_component.toggle_stance()
	hurtbox_component.toggle_stance()
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	movement_component.toggle_movement()


func _on_airborne_state_entered() -> void:
	animation_component.play("airborne")
	hurtbox_component.toggle_airborne()


func _on_airborne_state_exited() -> void:
	hurtbox_component.toggle_airborne()


func _on_airborne_state_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		try_stand_fire()

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


func _on_to_grounded_taken() -> void:
	animation_component.start("stand")

func _can_shoot():
	can_shoot = !can_shoot
	
	
func _on_died():
	state_chart.send_event("dead")


func _on_dead_state_entered() -> void:
	animation_component.start("dead")
	movement_component.disabled = true
	died.emit()
	
func _state_chart_event(event: String):
	state_chart.send_event(event)
	
func get_floor() -> int:
	return floor_detector_component.get_floor()
	
func set_floor(new_floor):
	floor_detector_component.set_starting_floor(new_floor)
