class_name AnimationComponent
extends Node

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
#	var current_animation = state_machine_legs.get_current_node()
#	print(current_animation)
	animation_legs.stop()
	state_machine_legs.travel(to_play)

func move(x: float):
	animation_tree["parameters/StateMachineLegs/move/blend_position"] = x

func shoot():
	#if animation_torso.is_playing():
	#	animation_torso.stop()
	#animation_torso.play("torso/shoot")
	#state_machine_legs.travel("shoot")
	state_machine_torso.travel("torso_shoot")
	var current_animation = state_machine_legs.get_current_node()
	print(current_animation)
