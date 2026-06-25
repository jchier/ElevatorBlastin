extends Area2D


func _ready():
	area_entered.connect(_on_area_entered)


func _on_area_entered(other_area: Area2D):
	if other_area is not Elevator:
		return

	
