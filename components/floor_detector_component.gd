class_name FloorDetectorComponent
extends Area2D

@export var starting_floor: int

var current_floor: int

func _ready():
	current_floor = starting_floor

func set_starting_floor(_starting_floor):
	current_floor = _starting_floor

func set_current_floor(new_floor: int):
	if current_floor == 0:
		current_floor = new_floor - 1
		return
	current_floor = new_floor
	#print("current floor = ", current_floor)

func get_floor() -> int:
	return current_floor
	
