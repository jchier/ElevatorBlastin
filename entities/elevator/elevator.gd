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
	wait_timer.timeout.connect(on_wait_timer_timeout)
	
func _physics_process(_delta: float) -> void:
#	if poly_set == false:
#		if detect_ceiling.is_colliding():
#			elevator_shaft_top = detect_ceiling.get_collision_point()
#		if detect_floor.is_colliding():
#			elevator_shaft_bottom = detect_floor.get_collision_point()
#		if elevator_shaft_bottom != Vector2.ZERO and elevator_shaft_top != Vector2.ZERO:
##			build_elevator_shaft()
#			poly_set = true
	
	if wait_timer.is_stopped():
		velocity.y = direction * elevator_speed
		move_and_slide()
		

	#when the elevator touches the ground or ceiling?
	if is_on_floor() and wait_timer.is_stopped() or is_on_ceiling() and wait_timer.is_stopped():
		wait_timer.start()
		_flip_direction()
		
	#when the elevator reaches intermediate stop
	stopped.emit()
	

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
		
func on_wait_timer_timeout():
	pass

func _on_floor_area_entered(_body: Node2D):
	wait_timer.start()

func request_up():
	if is_occupied:
		return
	direction = Global.UP
		
func request_down():
	if is_occupied:
		return
	direction = Global.DOWN

func _on_occupant_area_body_entered(body: Node2D) -> void:
	is_occupied = true


func _on_occupant_area_body_exited(body: Node2D) -> void:
	is_occupied = false
