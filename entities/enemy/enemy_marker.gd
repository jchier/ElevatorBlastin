class_name EnemyMarker
extends Marker2D

const ENEMY_SCENE: PackedScene = preload("uid://bftk50lxpoojr")


func spawn_enemy():
	var enemy_scene: Enemy = Enemy.new_enemy(false)
	add_child(enemy_scene)
	enemy_scene.global_position = global_position
	enemy_scene.reset_physics_interpolation()
