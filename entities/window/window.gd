extends Node2D

const WINDOW_COLLISION_LAYER: int = 20
const BREAK_FRAME: int = 3
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var static_collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D



func disable_collision():
	collision_shape_2d.set_deferred("disabled", true)
	static_collision_shape_2d.set_deferred("disabled", true)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	sprite_2d.frame = sprite_2d.frame + 1
	if sprite_2d.frame == BREAK_FRAME:
		disable_collision()
