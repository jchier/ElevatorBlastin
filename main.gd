extends Node

const PLAYER_SCENE: PackedScene = preload("uid://c2rgnnuoe4mpu")

var level_one = preload("uid://cflxxyn4pet7d")
var level: Node

func _ready():
	level = level_one.instantiate()
	add_child(level)
	spawn_player()
		
func spawn_player():
	for player_marker in level.get_children():
		if player_marker is PlayerMarker:
			var player_scene: Player = PLAYER_SCENE.instantiate()
			add_child(player_scene)
			player_scene.global_position = player_marker.global_position
			GameEvent.player_spawned.emit(player_scene)
