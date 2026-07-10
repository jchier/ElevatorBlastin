class_name AnimationComponent
extends Node

signal can_shoot
signal stance_changed

@export var animation_torso: AnimationPlayer
@export var animation_legs: AnimationPlayer
@export var animation_tree: AnimationTree
@onready var state_machine_legs: AnimationNodeStateMachinePlayback = \
animation_tree.get("parameters/StateMachineLegs/playback")
@onready var state_machine_torso: AnimationNodeStateMachinePlayback = \
animation_tree.get("parameters/StateMachineTorso/playback")

func play_idle():
	animation_tree.travel("idle")

func play_walk():
	state_machine_legs.travel("walk")
	
func play_duck():
	state_machine_legs.travel("duck")
	
func play(to_play: String):
	state_machine_torso.travel(to_play)
	state_machine_legs.travel(to_play)
	
func start(to_play: String):
	state_machine_torso.start(to_play)
	state_machine_legs.start(to_play)
	
func move(x: float):
	animation_tree["parameters/StateMachineLegs/move/blend_position"] = x

func stand_shoot():
	if state_machine_torso.get_current_node() == "duck_shoot":
		state_machine_torso.travel("shoot")
		return
	state_machine_torso.start("shoot")

func duck_shoot():
	if state_machine_torso.get_current_node() == "shoot":
		state_machine_torso.travel("duck_shoot")
		return
	state_machine_torso.start("duck_shoot")

func _can_shoot():
	can_shoot.emit()
	
func _stance_changed():
	stance_changed.emit()

func dead():
	state_machine_torso.start("dead")
	
func is_animation_playing() -> bool:
	if animation_torso.is_playing() or animation_legs.is_playing():
		return true
	return false
