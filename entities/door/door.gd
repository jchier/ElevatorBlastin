class_name Door
extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var static_collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var use_area: Area2D = $UseArea
@onready var collision_shape_2d: CollisionShape2D = $UseArea/CollisionShape2D

@export var locked: bool = false
var open: bool = false
var dir_opened: String
@export var disabled: bool = false:
	set(value):
		static_collision_shape_2d.set_deferred("disabled", value)
		static_body_2d.set_collision_layer_value(9, !value)

func _on_use_area_body_entered(body: Node2D) -> void:
	if !open and body is Player:
		if body.global_position.direction_to(global_position).x > 0:

			animation_player.play("open_l")
			dir_opened = "open_l"
		else:
			animation_player.play("open_r")
			dir_opened = "open_r"
		#print(body.global_position.direction_to(global_position).x)
		open = true



func _on_use_area_body_exited(enemy: Node2D) -> void:
	if open and enemy is Enemy:
		for body in use_area.get_overlapping_bodies():
			if body is Player:
				return
		animation_player.play_backwards(dir_opened)
		open = false
