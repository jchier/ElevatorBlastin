class_name DoorHall
extends Node2D
signal document_get
@onready var interactive_component: InteractiveComponent = $InteractiveComponent
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body_marker: Marker2D = $BodyMarker
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var player_door: bool = false
var door_on_screen: bool = false
var player_has_entered: bool = false

func set_player_door(is_player_door_: bool) -> DoorHall:
	player_door = is_player_door_
	return self

func _ready():	
	interactive_component.act.connect(_act)
	visible_on_screen_notifier_2d.screen_entered.connect(screen_entered)
	visible_on_screen_notifier_2d.child_exiting_tree.connect(child_exiting_tree)
	if player_door:
		sprite_2d.modulate = Color.CRIMSON
		

func _act(body: CharacterBody2D):
	if body is Player and player_door:
		if player_has_entered:
			body.start_interaction_animation("interaction_complete")
			return
		player_act(body)
		player_has_entered = true
	elif body is Enemy:
		enemy_act(body)
	

func player_act(body: Player):
	body.movement_component.disabled = true
	var last_orientation: float = body.get_orientation() 
	body.set_orientation(1.0)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(body, "global_position", body_marker.global_position, 0.2)
	await tween.finished
	body.start_animation("enter")
	animation_player.play("open")
	await animation_player.animation_finished
	body.start_interaction_animation("exit")
	animation_player.play("open")
	await animation_player.animation_finished
	body.set_orientation(last_orientation)
	body.movement_component.disabled = false
	document_get.emit()
	
func enemy_act(body: Enemy):
	body.movement_component.disabled = true
	body.set_orientation(1.0)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(body, "global_position", body_marker.global_position, 0.2)
	await tween.finished
	body.start_animation("enter")
	animation_player.play("open")
	await animation_player.animation_finished
	body.despawn()
	
func screen_entered():
	door_on_screen = true
	
func child_exiting_tree():
	door_on_screen = false
