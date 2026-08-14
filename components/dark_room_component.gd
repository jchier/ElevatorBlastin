extends Area2D

@onready var rect_fg: Node2D = $RectFG
@onready var rect_bg: Node2D = $RectBG
@onready var timer: Timer = $Timer
@export var collision_shape: CollisionShape2D

func _ready():
	GameEvent.broken_lamp.connect(_on_lamp_broken)
	rect_fg.collision_shape = collision_shape
	rect_bg.collision_shape = collision_shape

func _on_lamp_broken(lamp: Lamp):
	for area in get_overlapping_areas():
		if lamp.dark_room_detector_component == area:
			rect_fg.show()
			rect_bg.show()
			timer.start()
			area.darken.emit()


func _on_timer_timeout() -> void:
	rect_fg.hide()
	rect_bg.hide()
	for area in get_overlapping_areas():		
		area.lighten.emit()
