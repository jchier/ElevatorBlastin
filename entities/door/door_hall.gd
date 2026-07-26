class_name DoorHall
extends Node2D

@onready var interactive_component: InteractiveComponent = $InteractiveComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body_marker: Marker2D = $BodyMarker

func _ready():
	interactive_component.act.connect(_act)


func _act(body: CharacterBody2D):
	body.movement_component.disabled = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(body, "global_position", body_marker.global_position, 0.2)
	await tween.finished
	body.start_animation("enter")
	animation_player.play("open")
	await animation_player.animation_finished
	body.movement_component.disabled = false
