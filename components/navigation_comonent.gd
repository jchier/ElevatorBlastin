class_name NavigationComponent
extends Node

signal navigation_complete
signal set_orientation(signf: float)

@export var _navigator: CharacterBody2D

const ELEVATOR_BUFFER: int = 40

var _destination: float
var _state: String
var _last_direction: float
var _direction: float

func set_direction(direction):
	_direction = direction

func get_direction() -> float:
	return _direction

func set_destination(destination_x: float):
	_last_direction = _direction
	_destination = destination_x
	if _navigator.global_position.x < destination_x:
		set_direction(1)
	elif _navigator.global_position.x > destination_x:
		set_direction(-1)
	else:
		set_direction(0)
	
	
func track_target(target_x: float):
	if _direction == 0:
		set_direction(_last_direction)
		
	if _direction == -1 and target_x > _navigator.global_position.x:
		set_direction(1)
	elif _direction == 1 and target_x < _navigator.global_position.x:
		set_direction(-1)
		
	set_orientation.emit(_direction)
	
	
	
	if _navigator.global_position.x > target_x:
		return -1
	elif _navigator.global_position.x < target_x:
		return 0
	return 0
	
#func arrived_at_destination() -> bool:
#	if global_position.distance_to(_destination) <= 1:
#		return true
#	return false
	
func navigate() -> float:
	if _navigator.global_position.x > _destination + 1:
		return -1
	elif _navigator.global_position.x < _destination - 1:
		return 1
	navigation_complete.emit()
	return 0
	
func navigate_to_elevator() -> float:
	if _navigator.global_position.x > _destination + ELEVATOR_BUFFER:
		return -1
	elif _navigator.global_position.x < _destination - ELEVATOR_BUFFER:
		return 1
	navigation_complete.emit()
	return 0

func reverse_direction():
	_direction *= -1


func on_docile_state_entered():
	set_direction(1)
	

func stop():
	_last_direction = _direction
	set_direction(0)
	
func _on_waiting_for_elevator(chosen_elevator: CharacterBody2D):
	set_direction(0)
	set_orientation.emit(signf(_navigator.global_position.x - _destination))
	if _navigator.global_position.x > chosen_elevator.global_position.x:
		set_destination(chosen_elevator.global_position.x + ELEVATOR_BUFFER)
	elif  _navigator.global_position.x <= chosen_elevator.global_position.x:
		set_destination(chosen_elevator.global_position.x - ELEVATOR_BUFFER)
