class_name InteractorComponent
extends Area2D

func try_interact(body: CharacterBody2D):
	for area in get_overlapping_areas():
		if area is InteractiveComponent:
			area.activate(body)
			break

	
