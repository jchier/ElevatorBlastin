extends Area2D


signal set_current_occupancy(occupancy: Occupant_Component)
signal clear_current_occupancy

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(other_area: Area2D):
	if other_area is not Occupant_Component:
		return

	set_current_occupancy.emit(other_area)

func _on_area_exited(occupancy: Occupant_Component):
	clear_current_occupancy.emit()
