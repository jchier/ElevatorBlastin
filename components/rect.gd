extends Node2D

@export var collision_shape: CollisionShape2D
var color := Color(0, 0, 0, 1)

func _draw():
	if !collision_shape:
		return

	var size = collision_shape.shape.size
	draw_rect(Rect2(-size/2, size), color)	
