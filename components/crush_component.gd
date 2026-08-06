extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if get_parent().velocity.y > 0 and body.is_on_floor():
		body.die()
