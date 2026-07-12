class_name Enemy
extends CharacterBody2D

signal died

const FLOOR_DISTANCE: int = 50
const ELEVATOR_BUFFER: int = 40
@onready var movement_component: MovementComponent = $MovementComponent
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
var _destination: Vector2
var destination_met: bool = true

func _ready():
	#player.is_close_connect(_player_is_close)
	rider_component.set_current_occupancy.connect(_set_current_occupancy)
	rider_component.clear_current_occupancy.connect(_clear_current_occupancy)
	movement_component.state_chart_event.connect(_state_chart_event)
	movement_component.set_orientation.connect(set_orientation)
	animation_component.can_shoot.connect(_can_shoot)
	animation_component.stance_changed.connect(_stance_changed)
	crouching_collision_shape.disabled = true
	health_component.died.connect(_on_died)
	state_chart.send_event("docile")
	direction = 1
	move_to.global_position = Vector2(0,0)
	reaction_timer.paused = true
	
func _physics_process(delta: float) -> void:

	movement_component.generate_velocity(delta, direction)
	move_and_slide()

	if _current_occupancy:	
		#TODO: insert elevator riding logic here
		pass

	if vision_ray.is_colliding():
		var collided = vision_ray.get_collider()
		if collided is Player:
			set_destination(collided.global_position)
			player = collided
		#TODO: put logic to change desired elivator or stairs here
		state_chart.send_event("aggro")
		return

func set_destination(destination: Vector2):
	last_direction = direction
	_destination = destination
	if global_position.x < destination.x:
		direction = 1
	elif global_position.x > destination.x:
		direction = -1
	else:
		direction = 0
	
		
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

func set_orientation(sign: float):
	if sign == 0:
		return
	set_direction(sign)
	bullet_component.flip_horizontal(sign)
	visuals.scale.x = sign
	vision_ray.scale.x = sign
	edge_detection.scale.x = sign
	edge_detection.position.x = sign
		
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

func set_direction(new_direction):
	direction = new_direction
	
func _state_chart_event(event: String):
	state_chart.send_event(event)
	
#====================================== BEHAVIOR STATES ===========================================================	
#====================================== DOCILE STATE ==============================================================
func _on_docile_state_entered() -> void:
	patrol_timer.paused = false
	reaction_timer.paused = true
	direction = last_direction
	

func _on_docile_state_exited() -> void:
	patrol_timer.paused = true
	
func _on_docile_state_physics_processing(delta: float) -> void:
	edge_detection.force_raycast_update()
	
	if !edge_detection.is_colliding() and is_on_floor():
		set_direction(direction * -1)



func _on_patrol_timer_timeout() -> void:
	movement_component.disabled = !movement_component.disabled
	if movement_component.disabled:
		if randi_range(0, 4 > 2):
			set_direction(direction * -1)
	#print("direction: ", direction)
	patrol_timer.start(randf_range(1,2))

#====================================== AGGRO STATE ==============================================================

func _on_aggro_state_entered() -> void:
	reaction_timer.paused = false
	reaction_timer.start(randf_range(0.5, 1.0))
	movement_component.disabled = false

func _on_aggro_state_processing(delta: float) -> void:
	edge_detection.force_raycast_update()
	if !_is_facing_player():
		flip_toward_player()

	if !edge_detection.is_colliding():
		last_direction = direction
		set_direction(0)

	#if !vision_ray.is_colliding() and _player_floor_relation() == EQUAL and !_is_facing_player():
	#elif !edge_detection.is_colliding() and !vision_ray.is_colliding():
	if !vision_ray.is_colliding() and _player_floor_relation() != EQUAL:
		state_chart.send_event("seek")
		#state_chart.send_event("docile")

	#print(reaction_timer.time_left)
	
func _on_reaction_timer_timeout() -> void:
#	if velocity.x != 0:
#		try_stand_fire()
	#else:		
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
	set_destination(chosen_elevator.global_position)
	reaction_timer.paused = true
	destination_met = true

func _on_seek_elevator_state_physics_processing(delta: float) -> void:
	edge_detection.force_raycast_update()

	if abs(global_position.x - _destination.x) < ELEVATOR_BUFFER:
		state_chart.send_event("waiting_for_elevator")
	else:
		set_destination(chosen_elevator.global_position)
	
	#if we arrive at our destination, stop and look towards the chosen elevator
	if global_position.x == _destination.x:
		destination_met = true
		direction = 0
		set_orientation(signf(global_position.direction_to(_destination).x))
	
	
func _on_waiting_for_elevator_state_entered() -> void:
	#if we are not at an edge, and the elevator is not on our floor, and we are directly
	#below the elevator, we must scoot to the side a bit.
	destination_met = false
	if global_position.x > chosen_elevator.global_position.x:
		set_destination(Vector2(chosen_elevator.global_position.x + ELEVATOR_BUFFER, global_position.y))
	elif global_position.x <= chosen_elevator.global_position.x:
		set_destination(Vector2(chosen_elevator.global_position.x - ELEVATOR_BUFFER, global_position.y))
	else:
		destination_met = true
		
func _on_waiting_for_elevator_state_physics_processing(delta: float) -> void:

	if arrived_at_destination():
		destination_met = true
		#set_orientation(signf(global_position.direction_to(chosen_elevator.global_position).x))
		set_orientation(signf(global_position.direction_to(chosen_elevator.global_position).x))
		set_direction(0)
	
	if destination_met == true:
		if _chosen_elevator_floor_relation() == ABOVE:
			chosen_elevator.request_up()
		elif _chosen_elevator_floor_relation() == BELOW:
			chosen_elevator.request_down()
		else:
			set_destination(chosen_elevator.global_position)
			destination_met = false

		
	if _current_occupancy:
		state_chart.send_event("in_elevator")
		
func _on_in_elevator_state_entered() -> void:
	last_direction = direction
	set_direction(0)


func _on_in_elevator_state_physics_processing(delta: float) -> void:
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
	vision_ray.enabled = false
	animation_component.start("dead")
	direction = 0
	died.emit()
	despawn_timer.start()


func _on_despawn_timer_timeout() -> void:
	queue_free()
	
#====================================== ============== =================================================================
func _is_facing_player() -> bool:
	var dir_to_player = global_position.direction_to(player.global_position).x
	if direction == -1 and dir_to_player < 0 or direction == 1 and dir_to_player > 0:
		return true
	return false

func _is_facing_elevator() -> bool:
	var dir_to_elevator = global_position.direction_to(chosen_elevator.global_position).x
	if direction == -1 and dir_to_elevator < 0 or direction == 1 and dir_to_elevator > 0:
		return true
	return false

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

func flip_toward_player():
	if !player:
		return
		
	if direction == 0:
		direction = last_direction
		
	if direction == -1 and player.global_position.x > global_position.x:
		direction = 1
	elif direction == 1 and player.global_position.x < global_position.x:
		direction = -1
		
	set_orientation(direction)
	
func arrived_at_destination() -> bool:
	if global_position.distance_to(_destination) <= 1:
		return true
	return false
