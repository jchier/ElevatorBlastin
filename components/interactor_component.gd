class_name InteractorComponent
extends Area2D

signal activate(CharacterBody2D)

func interact(body: CharacterBody2D):
	activate.emit(body)
	
