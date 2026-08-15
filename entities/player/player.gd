class_name Player
extends CharacterBody2D

const KNOCKBACK_POWER: int = 200
const STARTING_HEALTH: int = 3
const MG_FIRE_RATE: float = 0.1
const NORMAL_FIRE_RATE: float = 0.3
const MAX_AMMO: int = 200
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
@onready var hurt_timer: Timer = $HurtTimer
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var floor_detector_component: FloorDetectorComponent = $FloorDetectorComponent
@onready var sprite_2d_torso: Sprite2D = %Sprite2DTorso
@onready var interactor_component: InteractorComponent = $InteractorComponent
@onready var crush_component: Node2D = $CrushComponent
@onready var sound_component: Node = $CharacterSoundComponent
@onready var kick_hitbox: HitboxComponent = $KickHitbox
@onready var kick_hitbox_collision: CollisionShape2D = $KickHitbox/CollisionShape2D

signal died

	
var current_stairs: Stairs = null
var stairs_destination: Vector2

var _current_occupancy: Occupant_Component = null
var can_shoot: bool = false
var dead: bool = false
var current_fire_rate: float
var shoot_input_type

var ammo: int:
	set(value):
		ammo = value
		GameEvent.player_ammo_changed.emit(ammo)
		if ammo <= 0:
			has_machine_gun = false
	
@onready var has_machine_gun: bool:
	set(value):
		has_machine_gun = value
		if value:
			current_fire_rate = MG_FIRE_RATE
		else:
			current_fire_rate = NORMAL_FIRE_RATE
		GameEvent.player_gun_changed.emit(value)

var life_counter: int:
	set(value):
		life_counter = value
		GameEvent.player_lives_changed.emit(life_counter)

func disable_player(value: bool):
		#print("disabled set to ",value)
		kick_hitbox_collision.set_deferred("disabled", true)
		movement_component.disabled = value
		hurtbox_component.disabled = value
		crouching_collision_shape.set_deferred("disabled", value)
		standing_collision_shape.set_deferred("disabled", value)
		can_shoot = value
		
func _ready():
	rider_component.set_current_occupancy.connect(_set_current_occupancy)
	rider_component.clear_current_occupancy.connect(_clear_current_occupancy)
	movement_component.state_chart_event.connect(state_chart_event)
	movement_component.set_orientation.connect(set_orientation)
	movement_component.jump_good.connect(_jumped)
	animation_component.can_shoot.connect(_can_shoot)
	animation_component.interaction_complete.connect(_interaction_complete)
	health_component.health_changed.connect(_update_player_health)
	health_component.died.connect(_on_died)
	hurtbox_component.hit.connect(_knockback)
	kick_hitbox.hit_hurtbox.connect(_enemy_kicked)
	interactor_component.interaction_valid.connect(_valid_interaction)
	floor_detector_component.changed_floor.connect(_changed_floor)
	crush_component.crushed.connect(die)
	crouching_collision_shape.disabled = true
	_update_player_health(health_component.current_health)
	life_counter = 1
	has_machine_gun = false
	#_update_player_lives(life_counter)
	
func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("jump"):
		movement_component.jump()	
		
	var x_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	movement_component.generate_velocity(delta, x_input)
	if !crush_component.was_crushed:
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

func _jumped():
	sound_component.jump()
		
func try_duck_fire():
#	if !fire_rate_timer.is_stopped() and can_shoot and !is_on_wall():
#		return
	if fire_rate_timer.is_stopped():
		animation_component.duck_shoot()
		fire()
	
func try_stand_fire():
	if fire_rate_timer.is_stopped():
		animation_component.stand_shoot()
		fire()
	
func fire():
	sound_component.shoot()
	bullet_component.fire()
	fire_rate_timer.start(current_fire_rate)
	ammo = ammo - 1
func set_orientation(sign_f: float):
	movement_component.orientation = sign_f
	bullet_component.flip_horizontal(sign_f)
	visuals.scale.x = sign_f
		
func get_orientation() -> float:
	return movement_component.orientation

func _set_current_occupancy(occupancy: Occupant_Component):
		_current_occupancy = occupancy
		
func _clear_current_occupancy():
	_current_occupancy = null
	


func _on_stand_state_entered() -> void:
	movement_component.orientation_lock = false
	animation_component.start("stand")



func _on_duck_state_entered() -> void:
	bullet_component.toggle_stance()
	hurtbox_component.duck()
	standing_collision_shape.set_deferred("disabled", true)
	crouching_collision_shape.set_deferred("disabled", false)
	animation_component.play("duck")
	movement_component.toggle_movement()

func _on_duck_state_physics_processing(_delta: float) -> void:
	if !has_machine_gun:
		if Input.is_action_just_pressed("shoot"):
			try_duck_fire()
	else:
		if Input.is_action_pressed("shoot"):
			try_duck_fire()


func _on_duck_state_exited() -> void:
	bullet_component.toggle_stance()
	hurtbox_component.stand()
	standing_collision_shape.set_deferred("disabled", false)
	crouching_collision_shape.set_deferred("disabled", true)
	movement_component.toggle_movement()


func _on_airborne_state_entered() -> void:
	kick_hitbox_collision.set_deferred("disabled", false)
	animation_component.play("airborne")
	hurtbox_component.toggle_airborne()


func _on_airborne_state_physics_processing(_delta: float) -> void:
	if !has_machine_gun:
		if Input.is_action_just_pressed("shoot"):
			try_stand_fire()
	else:
		if Input.is_action_pressed("shoot"):
			try_stand_fire()

func _on_airborne_state_exited() -> void:
	hurtbox_component.toggle_airborne()
	kick_hitbox_collision.set_deferred("disabled", true)

#func _on_airborne_state_input(_event: InputEvent) -> void:
#	if !has_machine_gun:
#		if Input.is_action_just_pressed("shoot"):
#			try_stand_fire()
#	else:
#		if Input.is_action_pressed("shoot"):
#			try_stand_fire()
			
func _on_stand_state_physics_processing(_delta: float) -> void:
	#print(velocity.length_squared())
		if velocity.length_squared() <= 800:
				animation_component.play("idle")
		else:
				animation_component.play("move")
		animation_component.move(signf(velocity.y))	
	
		if Input.is_action_just_pressed("up"):
			interactor_component.try_interact(self)
		if !has_machine_gun:
			if Input.is_action_just_pressed("shoot"):
				try_stand_fire()
		else:
			if Input.is_action_pressed("shoot"):
				try_stand_fire()

#func _on_duck_state_input(_event: InputEvent) -> void:
#	if !has_machine_gun:
#		if Input.is_action_just_pressed("shoot"):
#			try_stand_fire()
#	else:
#		if Input.is_action_pressed("shoot"):
#			try_duck_fire()


#func _on_stand_state_input(_event: InputEvent) -> void:
#	if !has_machine_gun:
#		if Input.is_action_just_pressed("shoot"):
#			try_stand_fire()
#	else:
#		if Input.is_action_pressed("shoot"):
#			try_stand_fire()


func _on_to_grounded_taken() -> void:
	animation_component.start("stand")

func _can_shoot():
	can_shoot = !can_shoot
	
func _knockback(dir: int):
	if dead:
		return
	set_orientation(dir * -1)
	movement_component.orientation_lock = true
	hurt_timer.start()
	animation_component.start("hit")
	var knockback_direction: float = dir * KNOCKBACK_POWER
	velocity.x = knockback_direction
	move_and_slide()
	state_chart.send_event("to_hurt")

func _on_died():
	dead = true
	sound_component.hit()
	state_chart.send_event("dead")


func _on_dead_state_entered() -> void:
	hurt_timer.stop()
	hurt_timer.paused = true
	animation_component.start("dead")
	disable_player(true)
	movement_component.disabled = true
	hurtbox_component.disabled = true
	#despawn_timer.start()
	died.emit()

func _on_dead_state_exited() -> void:
	dead = false
	hurt_timer.paused = false
	disable_player(false)
	movement_component.disabled = false
	hurtbox_component.disabled = false
	crush_component.was_crushed = false
	
func state_chart_event(event: String):
	state_chart.send_event(event)
	
func get_floor() -> int:
	return floor_detector_component.get_floor()
	

func start_animation(to_play: String):
	animation_component.start(to_play)

func start_interaction_animation(to_play: String):
	animation_component.start(to_play)
	await animation_component.interaction_complete
	state_chart.send_event("to_stand_from_interact")
	
func _interaction_complete():
	pass

func finish_interaction():
	state_chart.send_event("to_stand_from_interact")	


func _valid_interaction():
	state_chart.send_event("interact")


func _changed_floor():
	GameEvent.player_changed_floor.emit()
	
func die():
	state_chart.send_event("dead")


func _on_interacting_state_entered() -> void:
	disable_player(true)


func _on_interacting_state_exited() -> void:
	#set_orientation(last_orientation)
	disable_player(false)
	velocity = Vector2.ZERO


func _on_hurt_timer_timeout() -> void:
	state_chart.send_event("to_stand")


func _on_hurt_state_exited() -> void:
	velocity.x = 0
	
func _update_player_health(health: int):
	GameEvent.player_health_changed.emit(health)

func _update_player_lives(lives: int):
	GameEvent.player_lives_changed.emit(lives)

func health_up():
	health_component.current_health += 1
func life_up():
	life_counter += 1
func get_mg():
	has_machine_gun = true
	ammo = MAX_AMMO
	
func respawn(spawn_location: Vector2) -> void:
	if life_counter <= 0:
		GameEvent.gameover.emit()
	else:
		life_counter = life_counter - 1
		health_component.current_health = STARTING_HEALTH
		global_position = spawn_location
		reset_physics_interpolation()
		state_chart.send_event("to_stand")


func _enemy_kicked(_hurtbox_component: HurtboxComponent):
	GameEvent.add_score.emit(Global.SCORE_ENEMY_KICKED)
