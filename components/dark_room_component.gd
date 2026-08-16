extends Area2D

@onready var rect_fg: Node2D = $RectFG
@onready var rect_bg: Node2D = $RectBG
@onready var timer: Timer = $Timer
@export var collision_shape: CollisionShape2D



var lamps: Array

func _ready():
	GameEvent.broken_lamp.connect(_on_lamp_hit)
	rect_fg.collision_shape = collision_shape
	rect_bg.collision_shape = collision_shape


func _on_lamp_hit():
	_initialize_lamps()


func _on_timer_timeout() -> void:
	rect_fg.hide()
	rect_bg.hide()
	for area in get_overlapping_areas():		
		area.lighten.emit()

func _initialize_lamps() -> void:
	var areas: Array = get_overlapping_areas()
	assert(areas.size() > 0, "dark room areas array has no elements")
	for area in get_overlapping_areas():
		if area.is_in_group("lamp"):
			if !area.get_parent().broken.is_connected(_on_lamp_broken):
				area.get_parent().broken.connect(_on_lamp_broken)
				lamps.append(area)
			
		
func _on_area_exited(area: Area2D) -> void:
	area.lighten.emit()
	
func _on_lamp_broken():
	for area in get_overlapping_areas():
		area.darken.emit()
	rect_fg.show()
	rect_bg.show()
	timer.start(Global.DARKEN_LENGTH)
			
