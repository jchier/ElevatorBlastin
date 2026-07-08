class_name Enemy
extends CharacterBody2D

@onready var movement_component: MovementComponent = $MovementComponent
@onready var patrol_timer: Timer = $PatrolTimer
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
@onready var vision_ray: RayCast2D = $RayCast2D
@onready var edge_detection: RayCast2D = $EdgeDetection
@onready var move_to: Marker2D = $MoveTo


var direction: int = 1
var last_direction: int = 1
var can_move: bool = true
var _current_occupancy: Occupant_Component = null
var was_idle:bool = false
var can_shoot: bool = false
var patrol: bool = false
var t = 0

func _ready():
	rider_component.set_current_occupancy.connect(_set_current_occupancy)
	rider_component.clear_current_occupancy.connect(_clear_current_occupancy)
	movement_component.state_chart_event.connect(_state_chart_event)
	movement_component.set_orientation.connect(set_orientation)
	animation_component.can_shoot.connect(_can_shoot)
	crouching_collision_shape.disabled = true
	state_chart.send_event("docile")
	direction = 1
	move_to.global_position = Vector2(0,0)
	
func _physics_process(delta: float) -> void:
	
	if !edge_detection.is_colliding():
		set_direction(direction * -1)

	movement_component.generate_velocity(delta, direction)
	print(velocity)
	move_and_slide()

	if _current_occupancy:	
		#TODO: insert elevator riding logic here
		pass

	if vision_ray.is_colliding():
		state_chart.send_event("aggro")
		return
		


		
func try_duck_fire():
	if !fire_rate_timer.is_stopped() and can_shoot:
		return
	animation_component.duck_shoot()
	bullet_component.fire()
	fire_rate_timer.start()
	
func try_stand_fire():
	if !fire_rate_timer.is_stopped() and can_shoot:
		return
	animation_component.stand_shoot()
	bullet_component.fire()
	fire_rate_timer.start()

func set_orientation(signf: float):
	if signf == 0:
		return
	set_direction(signf)
	bullet_component.flip_horizontal()
	visuals.scale.x = signf
	vision_ray.scale.x = signf
	edge_detection.scale.x = signf
	edge_detection.position.x = signf
		
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
	movement_component.is_enabled = false


func _on_duck_state_exited() -> void:
	bullet_component.toggle_stance()
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	movement_component.is_enabled = true


func _on_airborne_state_entered() -> void:
	animation_component.play("airborne")


func _on_stand_state_physics_processing(_delta: float) -> void:
	if velocity.length_squared() <= 0.555:
			animation_component.play("idle")
	else:
			animation_component.play("move")
		
	animation_component.move(signf(velocity.y))	


func _on_to_grounded_taken() -> void:
	animation_component.start("stand")

func _can_shoot():
	can_shoot = !can_shoot


func _on_aggro_state_entered() -> void:
	try_stand_fire()


#func _on_docile_state_processing(_delta: float) -> void:
#	if patrol_timer.is_stopped():
#		movement_component.is_enabled = false
#		patrol_timer.start(randf_range(1,2))
#	else:
#		movement_component.is_enabled = true
	#print(patrol_timer.time_left)
	#print(set_direction)

func _on_patrol_timer_timeout() -> void:
	movement_component.is_enabled = !movement_component.is_enabled
	if !movement_component.is_enabled:
		if randi_range(0, 4 > 2):
			set_direction(direction * -1)
	print("direction: ", direction)
	print("movement enabled: ", movement_component.is_enabled)
	patrol_timer.start(randf_range(1,2))
	
func _state_chart_event(event: String):
	state_chart.send_event(event)
	
func set_direction(new_direction):
	direction = new_direction
	
