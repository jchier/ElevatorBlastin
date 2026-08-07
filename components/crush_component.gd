extends Node2D
@onready var ray_up: RayCast2D = $RayUp
@onready var ray_down: RayCast2D = $RayDown
signal crushed

func _process(_delta):
	if ray_up.is_colliding() and ray_down.is_colliding():
		crushed.emit()
