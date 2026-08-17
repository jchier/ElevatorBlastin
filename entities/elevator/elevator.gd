class_name Elevator
extends CharacterBody2D

signal stopped


@onready var occupant_area: Occupant_Component = $Occupant_Area
@onready var wait_timer: Timer = $WaitTimer
@onready var floor_area: Area2D = $Floor_Area
@onready var floor_animatable_body: AnimatableBody2D = $Floor_Animatable_Body
@onready var floor_detector_component: FloorDetectorComponent = $FloorDetectorComponent
@onready var roof_animatable_body: CrushingObjectComponent = $RoofAnimatableBody
@export var locked: bool = false
@onready var digital_display: Label = $DigitalDisplay

var requested_direction: int
var direction: int:
	set(value):
		direction = value
		#print("elevator direction set to ", value)
		if value == 1:
			pass
var elevator_speed: float = 30.0
var is_occupied: bool
var highest_floor: int

func _ready():
	floor_animatable_body.sync_to_physics = false
	direction = Global.DOWN
	requested_direction = direction
	occupant_area._set_direction.connect(_set_direction)
	floor_animatable_body.crushed.connect(_generate_crush_score)
	roof_animatable_body.crushed.connect(_generate_crush_score)
	digital_display.text = str(get_floor())
	GameEvent.player_died.connect(_on_player_died)
	
func _physics_process(_delta: float) -> void:
	if locked:
		return
		
	if wait_timer.is_stopped():
		velocity.y = direction * elevator_speed
		move_and_slide()
		
	if get_floor() == highest_floor:
		request_down()

	#when the elevator touches the ground or ceiling?
	if is_on_floor() and wait_timer.is_stopped() \
	 or is_on_ceiling() and wait_timer.is_stopped():
		stopped.emit()
		wait_timer.start()
		if !is_occupied:
			_flip_direction()
		
func can_go_up() -> bool:
	if !is_on_ceiling() and get_floor() != highest_floor:
		return true
	return false
	
func can_go_down() -> bool:
	if !is_on_floor():
		return true
	return false
	

func go_up():
	if !is_on_ceiling():
		direction = Global.UP
	
func go_down():
	if !is_on_floor():
		direction = Global.DOWN

func _set_direction(_direction: int):
	wait_timer.stop()
	direction = _direction

func _flip_direction():
	if direction == Global.UP:
		direction = Global.DOWN
	else:
		direction = Global.UP
	
	requested_direction = direction

func request_up():
	requested_direction = Global.UP
		
func request_down():
	requested_direction = Global.DOWN

func activate_requested_dir():
	if !is_occupied:
		direction = requested_direction

func _on_occupant_area_body_entered(_body: Node2D) -> void:
	is_occupied = true
	locked = false

func _on_occupant_area_body_exited(_body: Node2D) -> void:
	is_occupied = false

func _on_wait_timer_timeout() -> void:
	activate_requested_dir()


func _on_floor_area_area_entered(_area: Area2D) -> void:
	if get_floor() > highest_floor:
		highest_floor = get_floor()
	activate_requested_dir()
	stopped.emit()
	wait_timer.start()
	digital_display.text = str(get_floor())

func get_floor() -> int:
	return floor_detector_component.get_floor()
	
func _generate_crush_score():
	if occupant_area.player_occupied:
		GameEvent.add_score.emit(Global.SCORE_CRUSHED_ENEMY)
		
func _on_player_died():
	if occupant_area.player_occupied:
		digital_display.text = str("DAMN")
