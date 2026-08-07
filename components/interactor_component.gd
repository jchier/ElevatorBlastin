class_name InteractorComponent
extends Area2D

signal interaction_valid

func try_interact(body: CharacterBody2D):
	for area in get_overlapping_areas():
		if area is InteractiveComponent:
			interaction_valid.emit()
			area.activate(body)
			break

	
