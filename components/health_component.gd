class_name HealthComponent
extends Node


signal died
signal damaged(health: int)
signal health_changed(current_health: int)

@export var max_health: int = 1
var dead = false
var _current_health: int
var current_health: int: 
	get:
		return _current_health
	set(value):
		_current_health = value
		health_changed.emit(_current_health)
		if dead and current_health > 0:
			dead = false		

func _ready() -> void:
	current_health = max_health

func damage(_amount: int):
	if dead:
		died.emit()
		return
	current_health = current_health - 1
	damaged.emit(current_health)
	if current_health <= 0:
		dead = true
		died.emit()
