extends Node2D

const WINDOW_COLLISION_LAYER: int = 20
const BREAK_FRAME: int = 3
@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
var impact_particles_scene: PackedScene = preload("uid://brgnjm0t1n0ag")
@onready var static_body_2d: StaticBody2D = $StaticBody2D


func disable_collision():
	area_2d.queue_free()
	static_body_2d.queue_free()


func _on_area_2d_area_entered(_area: Area2D) -> void:
	sprite_2d.frame = sprite_2d.frame + 1
	if sprite_2d.frame == BREAK_FRAME:
		disable_collision()
		spawn_hit_particles()
		
func spawn_hit_particles():
	var hit_particles: Node2D = impact_particles_scene.instantiate()
	hit_particles.global_position = global_position
	get_parent().add_child(hit_particles)
