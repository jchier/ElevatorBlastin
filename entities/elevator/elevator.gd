class_name Elevator

extends CharacterBody2D
@onready var bumper_top: Area2D = $Bumper_Top
@onready var bumper_bottom: Area2D = $Bumper_Bottom
@onready var occupant_area: Occupant_Component = $Occupant_Area

var direction: int
var elevator_speed: float = 30.0

func _ready():
	direction = 0
	occupant_area._change_direction.connect(_change_direction)

func _physics_process(delta: float) -> void:
	velocity.y = direction * elevator_speed
	move_and_slide()

func go_up():
	direction = Global.UP
	
func go_down():
	direction = Global.DOWN

func _change_direction(_direction: int):
	direction = _direction
