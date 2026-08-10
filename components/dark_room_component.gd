extends Area2D

@onready var rect: Node2D = $Rect
@onready var timer: Timer = $Timer

func _ready():
	GameEvent.broken_lamp.connect(_on_lamp_broken)


func _on_lamp_broken(lamp: Lamp):
	for area in get_overlapping_areas():
		if lamp.dark_room_detector_component == area:
			rect.show()
			timer.start()
			
		area.darken.emit()


func _on_timer_timeout() -> void:
	rect.hide()
	for area in get_overlapping_areas():		
		area.darken.emit()
