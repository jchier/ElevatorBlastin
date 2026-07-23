class_name InteractiveComponent
extends Area2D

var _interactor: InteractorComponent = null
var body_close: bool = false

signal act(body: CharacterBody2D)

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func interactor_activated(body: CharacterBody2D):
	if _interactor == null:
		return
	act.emit(body)
	


func _on_area_entered(interactor: InteractorComponent) -> void:
	_interactor = interactor
	_interactor.activate.connect(interactor_activated)

func _on_area_exited(_area: Area2D) -> void:
	_interactor.activate.disconnect(interactor_activated)
	_interactor = null
