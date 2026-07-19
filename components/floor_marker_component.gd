class_name FloorMarkerComponent
extends Area2D

@export var floor_number: int



func _on_area_entered(area: Area2D):
	if area is not FloorDetectorComponent:
		return
	area.set_current_floor(floor_number)
