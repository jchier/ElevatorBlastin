class_name Occupant_Component
extends Area2D

var player_occupied: bool = false

signal _set_direction(direction: int)

func set_direction(direction: int):
	_set_direction.emit(direction)



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_occupied = true


func _on_body_exited(body: Node2D) -> void:
	player_occupied = false
