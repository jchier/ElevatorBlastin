class_name InteractiveComponent
extends Area2D

var body_close: bool = false

signal act(body: CharacterBody2D)


func activate(body: CharacterBody2D):
	act.emit(body)
	
