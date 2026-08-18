class_name InteractorComponent
extends Area2D

signal interaction_valid
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var disabled: bool:
	set(value):
		collision_shape_2d.set_deferred("disabled", value)

func try_interact(body: CharacterBody2D):
	for area in get_overlapping_areas():
		if area is InteractiveComponent:
			interaction_valid.emit()
			area.activate(body)
			break
