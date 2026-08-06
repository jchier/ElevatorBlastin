class_name FloorDetectorComponent
extends Area2D
@onready var label: Label = $Label

@export var starting_floor: int

signal changed_floor
var current_floor: int

func _ready():
	current_floor = starting_floor
	label.text = str(current_floor)

func set_starting_floor(_starting_floor):
	current_floor = _starting_floor
	label.text = str(current_floor)

func set_current_floor(new_floor: int):
	if new_floor != current_floor:
		call_deferred("emit_signal", "changed_floor")
	current_floor = new_floor
	label.text = str(current_floor)
	
func get_floor() -> int:
	return current_floor
	
