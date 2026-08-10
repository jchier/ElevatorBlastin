class_name EnemyManager
extends Node

const PLAYER_SPAWN_DISTANCE: float = 400000.0

var enemy_spawns: Array

func add_enemy_marker(enemy_marker: EnemyMarker):
	enemy_spawns.append(enemy_marker)
	
func _process(_delta: float):
	for enemy_marker in enemy_spawns:
		var squared_distance = GameState.player.global_position.distance_squared_to(enemy_marker.global_position)
		print(squared_distance)
		if squared_distance <= PLAYER_SPAWN_DISTANCE:
			enemy_marker.spawn_enemy()
			enemy_spawns.erase(enemy_marker)
		
