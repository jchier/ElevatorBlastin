extends Node

const PLAYER_SCENE: PackedScene = preload("uid://c2rgnnuoe4mpu")
const ENEMY_SCENE: PackedScene = preload("uid://bftk50lxpoojr")
const DOOR_HALL_SCENE: PackedScene = preload("uid://dmn4ui4jcf713")
var level_one = preload("uid://cflxxyn4pet7d")
var level: Node
var document_count: int = 0
var doors: Array

func _ready():
	level = level_one.instantiate()
	add_child(level)
	spawn_player()
	spawn_enemy()
	spawn_door_hall()
		
func spawn_player():
	for player_marker in level.get_children():
		if player_marker is PlayerMarker:
			var player_scene: Player = PLAYER_SCENE.instantiate()
			add_child(player_scene)
			player_scene.global_position = player_marker.global_position
			player_scene.set_floor(player_marker.starting_floor)

			GameEvent.player_spawned.emit(player_scene)

func spawn_enemy():
	for enemy_marker in level.get_children():
		if enemy_marker is EnemyMarker:
			var enemy_scene: Enemy = ENEMY_SCENE.instantiate()
			add_child(enemy_scene)
			enemy_scene.global_position = enemy_marker.global_position
			enemy_scene.set_floor(enemy_marker.starting_floor)
			
func spawn_door_hall():
	for door_hall_marker in level.get_children():
		if door_hall_marker is DoorHallMarker:
			var door_hall_scene: DoorHall = DOOR_HALL_SCENE.instantiate().set_player_door(door_hall_marker.player_door)
			if door_hall_scene.player_door:
				document_count = document_count + 1
				door_hall_scene.document_get.connect(got_document)
			add_child(door_hall_scene)
			doors.append(door_hall_scene)
			door_hall_scene.global_position = door_hall_marker.global_position
			
			#door_hall_scene.set_floor(door_hall_marker.starting_floor)

func got_document():
	document_count = document_count - 1
