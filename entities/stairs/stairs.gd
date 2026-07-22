class_name Stairs
extends Node2D

@onready var stairs_top_marker: Marker2D = $StairsTopMarker
@onready var stairs_bottom_marker: Marker2D = $StairsBottomMarker
@onready var stairs_top_area: Area2D = $StairsTopArea
@onready var stairs_bottom_area: Area2D = $StairsBottomArea

var _top_area_occupied: bool = false
var _bottom_area_occupied: bool = false

var rider = CharacterBody2D

func get_starting_point() -> Vector2:
	if _top_area_occupied:
		return stairs_top_marker.global_position
	return stairs_bottom_marker.global_position

func get_destination() -> Vector2:
	if _top_area_occupied:
		return stairs_bottom_marker.global_position
	return stairs_top_marker.global_position


func _on_stairs_top_area_body_entered(body: Node2D) -> void:
	_top_area_occupied = true
	rider = body
	rider.current_stairs = self

func _on_stairs_top_area_body_exited(_body: Node2D) -> void:
	_top_area_occupied = false
	rider.current_stairs = null
	rider = null

func _on_stairs_bottom_area_body_entered(body: Node2D) -> void:
	_bottom_area_occupied = true
	rider = body
	rider.current_stairs = self

func _on_stairs_bottom_area_body_exited(_body: Node2D) -> void:
	_bottom_area_occupied = false
	rider.current_stairs = null
	rider = null
