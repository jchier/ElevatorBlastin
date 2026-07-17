class_name Enemy
extends CharacterBody2D

signal died

const FLOOR_DISTANCE: int = 50
const ELEVATOR_BUFFER: int = 40
@onready var movement_component: MovementComponent = $MovementComponent
@onready var navigation_component: NavigationComponent = $NavigationComponent
@onready var rider_component: Area2D = $RiderComponent
@onready var visuals: Node = $Visuals
@onready var bullet_component: Node2D = $BulletComponent
@onready var state_chart: StateChart = $StateChart
@onready var standing_collision_shape: CollisionShape2D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape2D = $CrouchingCollisionShape
@onready var animation_component: Node = $AnimationComponent
@onready var vision_ray: RayCast2D = $VisionRay
@onready var edge_detection: RayCast2D = $EdgeDetection
@onready var move_to: Marker2D = $MoveTo
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var despawn_timer: Timer = $DespawnTimer
@onready var reaction_timer: Timer = $ReactionTimer
@onready var stance_timer: Timer = $StanceTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var cool_down_timer: Timer = $CoolDownTimer

@export var chosen_elevator: Elevator

enum {BELOW, EQUAL, ABOVE}

enum {UNDER_ELEVATOR, FAR_FROM_ELEVATOR}

var direction: int = 1
var last_direction: int = 1
var can_move: bool = true
var _current_occupancy: Occupant_Component = null
var was_idle:bool = false
var can_shoot: bool = false
var patrol: bool = false
var t = 0
var last_stance: String = "stand"
var callable_shoot
var player: Player
var destination_met: bool = true
var player_close = false

func _ready():
	rider_component.set_current_occupancy.connect(_set_current_occupancy)
	rider_component.clear_current_occupancy.connect(_clear_current_occupancy)
	movement_component.state_chart_event.connect(_state_chart_event)
	movement_component.set_orientation.connect(set_orientation)
	navigation_component.set_orientation.connect(set_orientation)
	animation_component.can_shoot.connect(_can_shoot)
	animation_component.stance_changed.connect(_stance_changed)
	crouching_collision_shape.disabled = true
	health_component.died.connect(_on_died)
	state_chart.send_event("docile")
	direction = 1
	move_to.global_position = Vector2(0,0)
	reaction_timer.paused = true
	
func _physics_process(delta: float) -> void:		
	movement_component.generate_velocity(delta, navigation_component.get_direction())
	move_and_slide()

	if vision_ray.is_colliding():
		var collided = vision_ray.get_collider()
		if collided is Player:
			navigation_component.set_destination(collided.global_position.x)
			player = collided
		state_chart.send_event("aggro")
		return
			
func try_duck_fire():
	if !fire_rate_timer.is_stopped() and can_shoot:
		return
	animation_component.duck_shoot()
	bullet_component.fire()
	fire_rate_timer.start()
	stance_timer.start()
	
func try_stand_fire():
	if !fire_rate_timer.is_stopped() and can_shoot:
		return
	animation_component.stand_shoot()
	bullet_component.fire()
	fire_rate_timer.start()

func set_orientation(sign_f: float):
	if sign_f == 0:
		return
	navigation_component.set_direction(sign_f)
	bullet_component.flip_horizontal(sign_f)
	visuals.scale.x = sign_f
	vision_ray.scale.x = sign_f
	edge_detection.scale.x = sign_f
	edge_detection.position.x = sign_f
		
func _set_current_occupancy(occupancy: Occupant_Component):
		_current_occupancy = occupancy
		state_chart.send_event("in_elevator")
		
func _clear_current_occupancy():
	_current_occupancy = null
	

func _on_stand_state_entered() -> void:
	animation_component.play("idle")



func _on_duck_state_entered() -> void:
	bullet_component.toggle_stance()
	hurtbox_component.toggle_stance()
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	animation_component.play("duck")
	movement_component.disabled = true


func _on_duck_state_exited() -> void:
	bullet_component.toggle_stance()
	hurtbox_component.toggle_stance()
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	movement_component.disabled = false


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

func _stance_changed() -> bool:
	return true
	
func _state_chart_event(event: String):
	state_chart.send_event(event)
	
#====================================== BEHAVIOR STATES ===========================================================	
#====================================== DOCILE STATE ==============================================================
func _on_docile_state_entered() -> void:
	patrol_timer.paused = false
	navigation_component.on_docile_state_entered()

func _on_docile_state_exited() -> void:
	patrol_timer.paused = true
	
func _on_docile_state_physics_processing(_delta: float) -> void:
	edge_detection.force_raycast_update()
	
	if !edge_detection.is_colliding() and is_on_floor()\
	or is_on_wall():
		navigation_component.reverse_direction()



func _on_patrol_timer_timeout() -> void:
	movement_component.disabled = !movement_component.disabled
	if movement_component.disabled:
		if randi_range(0, 4 > 2):
			navigation_component.reverse_direction()

	patrol_timer.start(randf_range(1,2))

#====================================== AGGRO STATE ==============================================================

func _on_aggro_state_entered() -> void:
	reaction_timer.paused = false
	reaction_timer.start(randf_range(0.5, 1.0))
	movement_component.disabled = false
	cool_down_timer.start()

func _on_aggro_state_processing(_delta: float) -> void:
	edge_detection.force_raycast_update()
	navigation_component.track_target(player.global_position.x)

	if !edge_detection.is_colliding():
		navigation_component.stop()


	if !vision_ray.is_colliding() and _player_floor_relation() != EQUAL:
		if chosen_elevator:
			state_chart.send_event("seek")
		else:
			state_chart.send_event("docile")

	
func _on_reaction_timer_timeout() -> void:	
	if randi_range(0, 4) > 1:
		if last_stance != "stand":
			#print("stand")
			state_chart.send_event("stand")
			await animation_component.stance_changed
			#print("stance changed to stand")
			movement_component.disabled = false
			last_stance = "stand"
		callable_shoot = try_stand_fire
	else:
		if last_stance != "duck":
			movement_component.disabled = true
			#print("duck")
			state_chart.send_event("duck")
			await animation_component.stance_changed
			#print("stance changed to duck")
			last_stance = "duck"
		callable_shoot = try_duck_fire
	if vision_ray.is_colliding():
		callable_shoot.call()	
	reaction_timer.start(randf_range(0.5, 1.0))
	
func _on_aggro_state_exited() -> void:
	reaction_timer.paused = true

#====================================== SEEKING STATE ==============================================================

func _on_seek_elevator_state_entered() -> void:
	state_chart.send_event("stand")
	navigation_component.navigation_complete.connect(arrived_to_elevator_stop)
	navigation_component.set_destination(chosen_elevator.global_position.x)

func _on_seek_elevator_state_physics_processing(_delta: float) -> void:
	edge_detection.force_raycast_update()
	navigation_component.navigate_to_elevator()

func arrived_to_elevator_stop():
	navigation_component.stop()
	state_chart.send_event("waiting_for_elevator")
	
func _on_seek_elevator_state_exited() -> void:
		navigation_component.navigation_complete.disconnect(arrived_to_elevator_stop)
	
func _on_waiting_for_elevator_state_entered() -> void:
	chosen_elevator.stopped.connect(elevator_stopped)
	navigation_component.navigation_complete.connect(navigation_complete)
	set_orientation(signf(global_position.direction_to(chosen_elevator.global_position).x))
	if global_position.x > chosen_elevator.global_position.x:
		navigation_component.set_destination(chosen_elevator.global_position.x + ELEVATOR_BUFFER)
	elif global_position.x <= chosen_elevator.global_position.x:
		navigation_component.set_destination(chosen_elevator.global_position.x - ELEVATOR_BUFFER)
		
func _on_waiting_for_elevator_state_physics_processing(_delta: float) -> void:
	navigation_component.navigate()
	if _current_occupancy:
		state_chart.send_event("in_elevator")

func _on_waiting_for_elevator_state_exited() -> void:
	chosen_elevator.stopped.disconnect(elevator_stopped)
	navigation_component.navigation_complete.disconnect(navigation_complete)
	
func _on_in_elevator_state_entered() -> void:
	navigation_component.stop()

func _on_in_elevator_state_physics_processing(_delta: float) -> void:
	if player.global_position.y < global_position.y - 4:
		chosen_elevator.go_up()
	elif player.global_position.y > global_position.y + 4:
		chosen_elevator.go_down()
	else:
		state_chart.send_event("docile")
		

#====================================== DEAD STATE =================================================================
	
func _on_died():
	state_chart.send_event("dead")

func _on_dead_state_entered() -> void:
	hurtbox_component.disabled = true
	vision_ray.enabled = false
	animation_component.start("dead")
	navigation_component.stop()
	movement_component.disabled = true
	hurtbox_component.disabled = true
	died.emit()
	despawn_timer.start()


func _on_despawn_timer_timeout() -> void:
	queue_free()
	
#====================================== ============== =================================================================
func _player_floor_relation() -> int:
	if !player:
		return -1
	if player.global_position.y < global_position.y - FLOOR_DISTANCE:
		return ABOVE
	if player.global_position.y > global_position.y + FLOOR_DISTANCE:
		return BELOW
	else:
		return EQUAL

func _chosen_elevator_floor_relation() -> int:
	if !chosen_elevator:
		return -1
	if chosen_elevator.global_position.y < global_position.y - 3:
		return BELOW
	if chosen_elevator.global_position.y > global_position.y + 3:
		return ABOVE
	else:
		return EQUAL

func elevator_stopped():
	print("elevator stopped")
	if _chosen_elevator_floor_relation() == ABOVE:
		chosen_elevator.request_up()
	elif _chosen_elevator_floor_relation() == BELOW:
		chosen_elevator.request_down()
	elif !_current_occupancy:
		navigation_component.set_destination(chosen_elevator.global_position.x)
	

func navigation_complete():
	set_orientation(signf(global_position.direction_to(chosen_elevator.global_position).x))
	navigation_component.stop()

func _on_player_buffer_zone_body_entered(_body: Node2D) -> void:
	player_close = true


func _on_player_buffer_zone_body_exited(_body: Node2D) -> void:
	player_close = false



func _on_cool_down_timer_timeout() -> void:
	if !_current_occupancy:
		state_chart.send_event("docile")
