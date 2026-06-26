class_name Occupant_Component
extends Area2D

signal _set_direction(direction: int)

func set_direction(direction: int):
	_set_direction.emit(direction)
