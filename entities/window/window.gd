extends Node2D

const WINDOW_COLLISION_LAYER: int = 20
const BREAK_FRAME: int = 3
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var static_collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var glass_particles: Node2D = $GlassParticles
var impact_particles_scene: PackedScene = preload("uid://brgnjm0t1n0ag")


func disable_collision():
	collision_shape_2d.set_deferred("disabled", true)
	static_collision_shape_2d.set_deferred("disabled", true)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	sprite_2d.frame = sprite_2d.frame + 1
	if sprite_2d.frame == BREAK_FRAME:
		disable_collision()
		spawn_hit_particles()
		
func spawn_hit_particles():
	var hit_particles: Node2D = impact_particles_scene.instantiate()
	hit_particles.global_position = global_position
	get_parent().add_child(hit_particles)
