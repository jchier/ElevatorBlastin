class_name Occupant_Component
extends Area2D

signal _change_direction(direction: int)

func change_direction(direction: int):
	_change_direction.emit(direction)
