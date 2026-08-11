class_name WinDetectorComponent
extends Area2D

signal check_win

func _on_area_entered(_area: Area2D) -> void:
	check_win.emit()
