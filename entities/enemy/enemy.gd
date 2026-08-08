class_name Enemy
extends CharacterBody2D

signal enemy_despawn

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
@onready var elevator_vision_ray: RayCast2D = $ElevatorVisionRay
@onready var player_vision_ray: RayCast2D = $PlayerVisionRay
@onready var edge_detection: RayCast2D = $EdgeDetection
@onready var move_to: Marker2D = $MoveTo
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var interactor_component: InteractorComponent = $InteractorComponent
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var despawn_timer: Timer = $DespawnTimer
@onready var reaction_timer: Timer = $ReactionTimer
@onready var stance_timer: Timer = $StanceTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var cool_down_timer: Timer = $CoolDownTimer
@onready var floor_detector_component: FloorDetectorComponent = $FloorDetectorComponent
@onready var elevator_floor_detector: RayCast2D = $ElevatorFloorDetector
@onready var crush_component: Node2D = $CrushComponent
@onready var floor_detector_collision_shape_2d: CollisionShape2D = $FloorDetectorComponent/CollisionShape2D

var chosen_elevator: Elevator
@export var starting_floor: int


enum {BELOW, EQUAL, ABOVE}
var disabled: bool = true:
	set(value):
		player_vision_ray.enabled = !value
		elevator_vision_ray.enabled = !value
		movement_component.disabled = value
		floor_detector_collision_shape_2d.set_deferred("disabled", value)
		#hurtbox_component.disabled = value
		
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
	player = GameState.player
	rider_component.set_current_occupancy.connect(_set_current_occupancy)
	rider_component.clear_current_occupancy.connect(_clear_current_occupancy)
	movement_component.state_chart_event.connect(_state_chart_event)
	movement_component.set_orientation.connect(set_orientation)
	navigation_component.set_orientation.connect(set_orientation)
	animation_component.can_shoot.connect(_can_shoot)
	animation_component.stance_changed.connect(_stance_changed)
	interactor_component.area_entered.connect(on_area_entered)
	interactor_component.interaction_valid.connect(valid_interaction)
	GameEvent.player_changed_floor.connect(_changed_floor)
	crush_component.crushed.connect(die)
	crouching_collision_shape.disabled = true
	health_component.died.connect(_on_died)
	state_chart.send_event("docile")
	direction = 1
	move_to.global_position = Vector2(0,0)
	reaction_timer.paused = true
	
	

func _on_alive_state_entered() -> void:
	animation_component.interaction_complete.connect(_interaction_complete)

func _on_alive_state_processing(delta: float) -> void:
	movement_component.generate_velocity(delta, navigation_component.get_direction())
	move_and_slide()

	if player_vision_ray.is_colliding():
		var collided = player_vision_ray.get_collider()
		if collided is Player:
			navigation_component.set_destination(collided.global_position.x)
			state_chart.send_event("aggro")
			return
				
	if _current_occupancy:
		state_chart.send_event("in_elevator")
	
	#if is_on_ceiling() and is_on_floor():
	#	state_chart.send_event("dead")	

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
	elevator_vision_ray.scale.x = sign_f
	player_vision_ray.scale.x = sign_f
	edge_detection.scale.x = sign_f
	edge_detection.position.x = sign_f
	elevator_floor_detector.scale.x = sign_f
	elevator_floor_detector.position.x = sign_f

func get_orientation() -> float:
	return movement_component.orientation

		
func _set_current_occupancy(occupancy: Occupant_Component):
		_current_occupancy = occupancy
		state_chart.send_event("in_elevator")
		
func _clear_current_occupancy():
	_current_occupancy = null
	

func _on_stand_state_entered() -> void:
	callable_shoot = try_stand_fire
	animation_component.play("idle")



func _on_duck_state_entered() -> void:
	callable_shoot = try_duck_fire
	bullet_component.toggle_stance()
	hurtbox_component.toggle_stance()
	standing_collision_shape.set_deferred("disabled", true)
	crouching_collision_shape.set_deferred("disabled", false)
	animation_component.play("duck")
	movement_component.disabled = true


func _on_duck_state_exited() -> void:
	bullet_component.toggle_stance()
	hurtbox_component.toggle_stance()
	standing_collision_shape.set_deferred("disabled", false)
	crouching_collision_shape.set_deferred("disabled", true)
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
	chosen_elevator = null
	patrol_timer.paused = false
	navigation_component.on_docile_state_entered()

func _on_docile_state_exited() -> void:
	patrol_timer.paused = true
	
func _on_docile_state_physics_processing(_delta: float) -> void:
	edge_detection.force_raycast_update()
	elevator_floor_detector.force_raycast_update()
	if !edge_detection.is_colliding() and is_on_floor()\
	or is_on_wall():
		navigation_component.reverse_direction()
		
	if elevator_floor_detector.is_colliding() and !chosen_elevator\
	and _player_floor_relation() != 0:
		var collider = elevator_floor_detector.get_collider()
		var elevator = collider.get_parent() as Elevator
		if elevator:
			chosen_elevator = elevator
			movement_component.jump()
			state_chart.send_event("go_in_elevator")



func _on_patrol_timer_timeout() -> void:
	if elevator_vision_ray.get_collider() is not Elevator and _player_floor_relation() != 0:
		movement_component.disabled = !movement_component.disabled
	if movement_component.disabled:
		var random_value = randi_range(0,4)
		if random_value <= 1:
			navigation_component.reverse_direction()
		if random_value >= 3:
			movement_component.disabled = false
			

	patrol_timer.start(randf_range(1,2))

#====================================== AGGRO STATE ==============================================================

func _on_aggro_state_entered() -> void:
	reaction_timer.paused = false
	reaction_timer.start(randf_range(0.0, 0.5))
	movement_component.disabled = false
	cool_down_timer.start()
	elevator_floor_detector.enabled = false
	#try_stand_fire()
	
func _on_aggro_state_processing(_delta: float) -> void:
	edge_detection.force_raycast_update()
	if !player_close:
		navigation_component.track_target(player.global_position.x)

	if !edge_detection.is_colliding() or player_close:
		navigation_component.stop()


	if _player_floor_relation() != 0:
			state_chart.send_event("docile")

func _on_reaction_timer_timeout() -> void:	
	reaction_timer.start(randf_range(0.5, 1.0))
	if randi_range(0, 4) > 1:
		if last_stance != "stand":
			state_chart.send_event("stand")
			await animation_component.stance_changed
			last_stance = "stand"

		#print("callable shoot = stand fire")
	else:
		if last_stance != "duck":
			state_chart.send_event("duck")
			await animation_component.stance_changed
			last_stance = "duck"
#		callable_shoot = try_duck_fire
		#print("callable shoot = duck fire")
	if player_vision_ray.is_colliding():
		callable_shoot.call()	
	
func _on_aggro_state_exited() -> void:
	state_chart.send_event("stand")
	reaction_timer.paused = true
	elevator_floor_detector.enabled = true

#====================================== SEEKING STATE ==============================================================

func _on_go_in_elevator_state_entered() -> void:
	navigation_component.navigation_complete.connect(inside_elevator)
	navigation_component.set_destination(chosen_elevator.global_position.x)

func _on_go_in_elevator_state_physics_processing(_delta: float) -> void:
	edge_detection.force_raycast_update()
	navigation_component.navigate()

func inside_elevator():
	navigation_component.stop()
	state_chart.send_event("in_elevator")
	
func _on_go_in_elevator_state_exited() -> void:
	navigation_component.navigation_complete.disconnect(inside_elevator)


func _on_in_elevator_state_entered() -> void:
	chosen_elevator.stopped.connect(make_elevator_choice)
	navigation_component.stop()
	make_elevator_choice()
	
func make_elevator_choice():
	if _player_floor_relation() > 0 and chosen_elevator.can_go_up():
		chosen_elevator.go_up()
	elif _player_floor_relation() < 0 and chosen_elevator.can_go_down():
		chosen_elevator.go_down()
	else:
		state_chart.send_event("get_off")
		
func _on_in_elevator_state_physics_processing(_delta: float) -> void:
	if chosen_elevator.is_on_floor() or chosen_elevator.is_on_ceiling():
		state_chart.send_event("get_off")


func _on_in_elevator_state_exited() -> void:
	chosen_elevator.stopped.disconnect(make_elevator_choice)

func _on_get_off_elevator_state_entered() -> void:
	navigation_component.start()

func _on_get_off_elevator_state_physics_processing(_delta: float) -> void:
	elevator_floor_detector.force_raycast_update()
	if !elevator_floor_detector.is_colliding():
		movement_component.jump()
		state_chart.send_event("docile")

#====================================== INTERACT STATE =================================================================
	
func _on_interact_state_entered() -> void:
	disabled = true


func _interaction_complete():
	state_chart.send_event("to_alive_from_interact")
	
func start_interaction_animation(to_play: String):
	animation_component.start(to_play)
	state_chart.send_event("to_alive_from_interact")	

func finish_interaction():
	state_chart.send_event("to_alive_from_interact")	

func valid_interaction():
	state_chart.send_event("interact")

func _on_interact_state_exited() -> void:
	disabled = false
#====================================== DEAD STATE =================================================================
	
func _on_died():
	state_chart.send_event("dead")

func _on_dead_state_entered() -> void:
	hurtbox_component.disabled = true
	elevator_vision_ray.enabled = false
	player_vision_ray.enabled = false
	animation_component.start("dead")
	navigation_component.stop()
	hurtbox_component.disabled = true
	despawn_timer.start()
	
func _on_dead_state_processing(delta: float) -> void:
	movement_component.generate_velocity(delta, 0)
	if !crush_component.was_crushed:
		move_and_slide()

func _on_despawn_timer_timeout() -> void:
	despawn()

func despawn():
	GameEvent.enemy_despawned.emit()
	queue_free()

#====================================== ============== =================================================================
func _player_floor_relation() -> int:
	#if player is on floor 5, and enemy is on floor 7,
	#return -2
	return player.get_floor() - get_floor()



func navigation_complete():
	set_orientation(signf(global_position.direction_to(chosen_elevator.global_position).x))
	navigation_component.stop()

func _on_player_buffer_zone_body_entered(_body: Node2D) -> void:
	if _body is not Player:
		return
	#navigation_component.stop()
	player_close = true


func _on_player_buffer_zone_body_exited(_body: Node2D) -> void:
	if _body is not Player:
		return
	player_close = false
	navigation_component.start()


func _on_cool_down_timer_timeout() -> void:
	if !_current_occupancy:
		state_chart.send_event("docile")

func get_floor() -> int:
	return floor_detector_component.get_floor()

	
func start_animation(to_play: String):
	animation_component.start(to_play)

func on_area_entered(interactive: InteractiveComponent):
	if interactive.is_in_group("stairs_top"):
		if _player_floor_relation() < 0:
			interactor_component.try_interact(self)
			
	if interactive.is_in_group("stairs_bottom"):
		if _player_floor_relation() > 0:
			interactor_component.try_interact(self)
			
	if interactive.is_in_group("door_hall") and _player_floor_relation() <= -2:
		
		print(player.get_floor(), get_floor(), _player_floor_relation())
		interactor_component.try_interact(self)
		
func die():
	state_chart.send_event("dead")

func _changed_floor():
	var player_floor_relation = _player_floor_relation()	
	if player_floor_relation >= -1 and player_floor_relation <= 1:
		player_vision_ray.enabled = true
	else:
		player_vision_ray.enabled = false


func _on_spawn_state_entered() -> void:
	animation_component.interaction_complete.connect(_spawn_complete)
	start_animation("exit")

func _spawn_complete():
	state_chart.send_event("to_alive")
	

func _on_spawn_state_exited() -> void:
	disabled = false
	animation_component.interaction_complete.disconnect(_spawn_complete)
