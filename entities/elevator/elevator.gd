class_name Elevator
extends CharacterBody2D

signal stopped

@onready var occupant_area: Occupant_Component = $Occupant_Area
@onready var wait_timer: Timer = $WaitTimer
@onready var floor_area: Area2D = $Floor_Area
@onready var floor_animatable_body: AnimatableBody2D = $Floor_Animatable_Body
@onready var ev_poly: CollisionPolygon2D = $ElevatorShaft/CollisionPolygon2D
@onready var detect_floor: RayCast2D = $Detect_Floor
@onready var detect_ceiling: RayCast2D = $Detect_Ceiling

var points: PackedVector2Array
var poly_set: bool = false
var requested_direction: int
var direction: int
var elevator_speed: float = 30.0
var is_occupied
var elevator_shaft_bottom: Vector2 = Vector2.ZERO
var elevator_shaft_top: Vector2 = Vector2.ZERO

#func build_elevator_shaft():
#	points.append(Vector2(elevator_shaft_top.x - 2, elevator_shaft_top.y))
#	points.append(Vector2(elevator_shaft_top.x + 2, elevator_shaft_top.y))
#	points.append(Vector2(elevator_shaft_bottom.x + 2, elevator_shaft_bottom.y))
#	points.append(Vector2(elevator_shaft_bottom.x - 2, elevator_shaft_bottom.y))
#	ev_poly.polygon = points

func _ready():
	floor_animatable_body.sync_to_physics = false
	direction = Global.DOWN
	occupant_area._set_direction.connect(_set_direction)
	floor_area.body_entered.connect(_on_floor_area_entered)
	
func _physics_process(_delta: float) -> void:
	
	if wait_timer.is_stopped():
		velocity.y = direction * elevator_speed
		move_and_slide()
		

	#when the elevator touches the ground or ceiling?
	if is_on_floor() and wait_timer.is_stopped() or is_on_ceiling() and wait_timer.is_stopped():
		stopped.emit()
		wait_timer.start()
		_flip_direction()
		
	#when the elevator reaches intermediate stop

	

func go_up():
	direction = Global.UP
	
func go_down():
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

func _on_floor_area_entered(_body: Node2D):
	activate_requested_dir()
	stopped.emit()
	wait_timer.start()

func request_up():
	requested_direction = Global.UP
		
func request_down():
	requested_direction = Global.DOWN

func activate_requested_dir():
	if !is_occupied:
		direction = requested_direction

func _on_occupant_area_body_entered(body: Node2D) -> void:
	is_occupied = true


func _on_occupant_area_body_exited(body: Node2D) -> void:
	is_occupied = false

func _on_wait_timer_timeout() -> void:
	activate_requested_dir()
