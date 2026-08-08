extends Node2D
@onready var ray_up: RayCast2D = $RayUp
@onready var ray_down: RayCast2D = $RayDown
@onready var timer: Timer = $Timer

const MAX_CRUSH: int = 100

signal crushed
var was_crushed: bool = false

var crush_amount: int = 0

func _process(_delta: float) -> void:
	if crush_amount >= MAX_CRUSH:
		was_crushed = true
		crushed.emit()
		return
		
	if ray_down.is_colliding() and ray_up.is_colliding():
		var up_col = ray_up.get_collider()
		var down_col = ray_down.get_collider()
		if up_col is AnimatableBody2D and up_col.get_parent().velocity.y > 1\
		or down_col is AnimatableBody2D and down_col.get_parent().velocity.y < -1:
			crush_amount = crush_amount + 1
			print(crush_amount)
	else:
		crush_amount = 0
		
		


		
