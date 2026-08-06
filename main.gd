extends Node

const PLAYER_SCENE: PackedScene = preload("uid://c2rgnnuoe4mpu")
const ENEMY_SCENE: PackedScene = preload("uid://bftk50lxpoojr")
const DOOR_HALL_SCENE: PackedScene = preload("uid://dmn4ui4jcf713")
const MAX_ENEMY_COUNT: int = 50
var level_one = preload("uid://cflxxyn4pet7d")
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
var level: Node
var document_count: int = 0
var doors: Array
var valid_spawn_door: Array
var enemy_count: int


func _ready():
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)
	level = level_one.instantiate()
	add_child(level)
	spawn_player()
#	spawn_enemy()
	spawn_door_hall()
	GameEvent.player_changed_floor.connect(_player_changed_floor)
	GameEvent.enemy_spawned.connect(_enemy_spawned)
	GameEvent.enemy_despawned.connect(_enemy_despawned)
	
func spawn_player():
	for player_marker in level.get_children():
		if player_marker is PlayerMarker:
			var player_scene: Player = PLAYER_SCENE.instantiate()
			add_child(player_scene)
			player_scene.global_position = player_marker.global_position
#			player_scene.set_floor(player_marker.starting_floor)

			GameEvent.player_spawned.emit(player_scene)
			


func spawn_enemy():
#	for enemy_marker in level.get_children():
#		if enemy_marker is EnemyMarker:
#			var enemy_scene: Enemy = ENEMY_SCENE.instantiate()
#			add_child(enemy_scene)
#			enemy_scene.global_position = enemy_marker.global_position
#			enemy_scene.set_floor(enemy_marker.starting_floor)

			
	#randomly select a door from among the doors on screen, ask it to spawn enemy
	var selected_door: DoorHall =\
	valid_spawn_door.get(randi_range(0, valid_spawn_door.size() - 1))
	if enemy_count <= MAX_ENEMY_COUNT:
		selected_door.spawn_enemy()
			
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
			
#			if door_hall_scene.can_spawn_enemy():
#				valid_spawn_door.append(door_hall_scene)
			
			#door_hall_scene.set_floor(door_hall_marker.starting_floor)

func got_document():
	document_count = document_count - 1


func _player_changed_floor():
	for door in doors:
		if door.can_spawn_enemy():
			valid_spawn_door.append(door)
		else:
			valid_spawn_door.erase(door)
			
func _enemy_spawned():
	enemy_count = enemy_count + 1

func _enemy_despawned():
	enemy_count = enemy_count - 1
	
func _on_enemy_spawn_timer_timeout():
	spawn_enemy()
	enemy_spawn_timer.start()
