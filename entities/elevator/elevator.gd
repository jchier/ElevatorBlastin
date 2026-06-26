class_name Elevator

extends CharacterBody2D
@onready var bumper_top: Area2D = $Bumper_Top
@onready var bumper_bottom: Area2D = $Bumper_Bottom
@onready var occupant_area: Occupant_Component = $Occupant_Area
@onready var wait_timer: Timer = $WaitTimer

var direction: int
var elevator_speed: float = 30.0

func _ready():
	direction = Global.DOWN
	occupant_area._set_direction.connect(_set_direction)
	wait_timer.timeout.connect(on_wait_timer_timeout)

func _physics_process(delta: float) -> void:
	if wait_timer.is_stopped():
		velocity.y = direction * elevator_speed
		move_and_slide()

	#what happens when the elevator touches the ground or ceiling?
	#if velocity.y == 0 and wait_timer.is_stopped():
	if is_on_floor() and wait_timer.is_stopped() or is_on_ceiling() and wait_timer.is_stopped():
		wait_timer.start()
		_flip_direction()


func go_up():
	direction = Global.UP
	
func go_down():
	direction = Global.DOWN

func _set_direction(_direction: int):
	direction = _direction

func _flip_direction():
	if direction == Global.UP:
		direction = Global.DOWN
	else:
		direction = Global.UP
		
func on_wait_timer_timeout():
	pass
