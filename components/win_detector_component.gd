class_name WinDetectorComponent
extends Area2D

signal check_win


func _on_body_entered(body: Node2D) -> void:
	check_win.emit()
