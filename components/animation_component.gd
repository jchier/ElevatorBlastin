class_name AnimationComponent
extends Node

@export var animation_torso: AnimationPlayer
@export var animation_legs: AnimationPlayer
@export var animation_tree: AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = \
animation_tree.get("parameters/playback")

func play_idle():
	animation_tree.travel("idle")

func play_walk():
	animation_state_machine.travel("walk")
	
func play_duck():
	animation_state_machine.travel("duck")
	
func play(to_play: String):
	animation_state_machine.travel(to_play)

func move(x: float):
	animation_tree["parameters/move/blend_position"] = x

func shoot():
	if animation_torso.is_playing():
		animation_torso.stop()
	animation_torso.play("torso/shoot")
