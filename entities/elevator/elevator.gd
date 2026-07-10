class_name Elevator
extends CharacterBody2D

signal stopped

@onready var occupant_area: Occupant_Component = $Occupant_Area
@onready var wait_timer: Timer = $WaitTimer
@onready var floor_area: Area2D = $Floor_Area
@onready var floor_animatable_body: AnimatableBody2D = $Floor_Animatable_Body

var direction: int
var elevator_speed: float = 30.0
var is_occupied

func _ready():
	floor_animatable_body.sync_to_physics = false
	direction = Global.DOWN
	occupant_area._set_direction.connect(_set_direction)
	floor_area.body_entered.connect(_on_floor_area_entered)
	wait_timer.timeout.connect(on_wait_timer_timeout)

func _physics_process(_delta: float) -> void:
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

func request():
	if is_occupied:
		return


func _on_occupant_area_body_entered(body: Node2D) -> void:
	is_occupied = true


func _on_occupant_area_body_exited(body: Node2D) -> void:
	is_occupied = false
