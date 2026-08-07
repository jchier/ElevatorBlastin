extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var use_l: Area2D = $Use_L
@onready var use_r: Area2D = $Use_R
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var static_collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var use_l_collision_shape_2d: CollisionShape2D = $Use_L/CollisionShape2D
@onready var use_r_collision_shape_2d: CollisionShape2D = $Use_R/CollisionShape2D

@export var locked: bool = false
var open: bool = false

func disable_collision():
	collision_shape_2d.set_deferred("disabled", true)
	use_l_collision_shape_2d.set_deferred("disabled", true)
	use_r_collision_shape_2d.set_deferred("disabled", true)
	static_collision_shape_2d.set_deferred("disabled", true)

func _on_use_l_body_entered(_body: Node2D) -> void:
	if !open:
		animation_player.play("open_l")
		disable_collision()
		open = true


func _on_use_r_body_entered(_body: Node2D) -> void:
	if !open:
		animation_player.play("open_r")
		disable_collision()
		open = true
