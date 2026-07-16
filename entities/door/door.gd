extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var use_l: Area2D = $Use_L
@onready var use_r: Area2D = $Use_R

@export var locked: bool = false
var open: bool = false



func _on_use_l_body_entered(body: Node2D) -> void:
	if !open:
		animation_player.play("open_l")
		open = true


func _on_use_r_body_entered(body: Node2D) -> void:
	if !open:
		animation_player.play("open_r")
		open = true
