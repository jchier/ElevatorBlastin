class_name Enemy
extends CharacterBody2D


@onready var patrol_timer: Timer = $PatrolTimer
@export var max_speed: float = 80.0
@export var jump_velocity: float = -200.0
@onready var camera: Camera2D = $Camera2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var rider_component: Area2D = $RiderComponent
@onready var visuals: Node = $Visuals
#@onready var animation_player_torso: AnimationPlayer = $AnimationPlayerTorso
#@onready var animation_player_legs: AnimationPlayer = $AnimationPlayerLegs
#@onready var bullet_marker_2d: Marker2D = $BulletMarker2D
@onready var bullet_container: Node2D = $BulletContainer
@onready var bullet_marker_2d: Marker2D = %BulletMarker2D
@onready var state_chart: StateChart = $StateChart
@onready var standing_collision_shape: CollisionShape2D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape2D = $CrouchingCollisionShape
#@onready var animation_tree: AnimationTree = $AnimationTree
#@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var animation_component: Node = $AnimationComponent
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var edge_detection: RayCast2D = $EdgeDetection

var bullet_scene: PackedScene = preload("uid://rnaqg1ycr0e1")
var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 1
var stance_distance_modifier = 18
var acceleration: float = 8.0
var friction: float = 10.0
var coyote_time_activated: bool = false
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
	state_chart.send_event("docile")
	direction = 1
	
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
	
	
	var velocity_weight : float = delta * acceleration
	velocity.x = lerp(velocity.x, direction * current_speed, velocity_weight)


	move_and_slide()


	if was_on_floor and not is_on_floor() and velocity.y > 0:
		state_chart.send_event("airborne")
	
	if direction < 0 and forward == true \
		or direction > 0 and forward == false:
		flip_horizontal()
	
	if _current_occupancy:	
		#TODO: insert elevator riding logic here
		pass

	if ray_cast_2d.is_colliding():
		state_chart.send_event("aggro")
		
	if !edge_detection.is_colliding():
		flip_horizontal()
		direction *= -1

		
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
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.global_position = bullet_marker_2d.global_position
	bullet.start(bullet_marker_2d.global_rotation)
	get_parent().add_child(bullet, true)
	fire_rate_timer.start()
	#TODO: fire rate timer, effects go here

func flip_horizontal():
	visuals.scale.x *= -1.0
	#bullet_marker_2d.position.x *= -1.0
	bullet_marker_2d.rotation *= -1.0
	bullet_container.scale.x *= -1
	ray_cast_2d.scale.x *= -1
	edge_detection.scale.x *= -1
	forward = !forward
	edge_detection.position.x *= -1
	#direction *= -1
		
func _set_current_occupancy(occupancy: Occupant_Component):
		_current_occupancy = occupancy
		
func _clear_current_occupancy():
	_current_occupancy = null
	


func _on_stand_state_entered() -> void:
	animation_component.start("stand")



func _on_duck_state_entered() -> void:
	bullet_marker_2d.global_position.y += stance_distance_modifier
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	animation_component.play("duck")
	current_speed = 0


func _on_duck_state_exited() -> void:
	bullet_marker_2d.global_position.y -= stance_distance_modifier
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	current_speed = max_speed


func _on_airborne_state_entered() -> void:
	animation_component.play("airborne")


func _on_stand_state_physics_processing(delta: float) -> void:
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


func _on_docile_state_processing(delta: float) -> void:
	#current_speed = 0
	if patrol_timer.is_stopped():
		direction *= -1
		current_speed = max_speed
		patrol_timer.start(randf_range(1,2))
