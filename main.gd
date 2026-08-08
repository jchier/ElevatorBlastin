extends Node

const PLAYER_SCENE: PackedScene = preload("uid://c2rgnnuoe4mpu")
const ENEMY_SCENE: PackedScene = preload("uid://bftk50lxpoojr")
const DOOR_HALL_SCENE: PackedScene = preload("uid://dmn4ui4jcf713")
const MAX_ENEMY_COUNT: int = 8
var level_one = preload("uid://cflxxyn4pet7d")
@onready var retry_timer: Timer = $RetryTimer
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var hud: CanvasLayer = $Hud
var level: Node
var document_count: int = 0
var doors: Array
var valid_spawn_door: Dictionary[DoorHall, int]
var selected_door: DoorHall
var enemy_count: int
var last_floor_spawned: int


func _ready():
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)
	level = level_one.instantiate()
	add_child(level)
	spawn_player()
	spawn_enemy()
	spawn_door_hall()
	hud.update_document_count(document_count)
	GameEvent.player_changed_floor.connect(_player_changed_floor)
	GameEvent.enemy_spawned.connect(_enemy_spawned)
	GameEvent.enemy_despawned.connect(_enemy_despawned)
	GameEvent.got_document.connect(_got_document)
	
func spawn_player():
	for player_marker in level.get_children():
		if player_marker is PlayerMarker:
			var player_scene: Player = PLAYER_SCENE.instantiate()
			add_child(player_scene)
			player_scene.global_position = player_marker.global_position
#			player_scene.set_floor(player_marker.starting_floor)
			player_scene.died.connect(_player_died)
			GameEvent.player_spawned.emit(player_scene)
			
func spawn_enemy():
	for enemy_marker in level.get_children():
		if enemy_marker is EnemyMarker:
			var enemy_scene: Enemy = Enemy.new_enemy(false)
			add_child(enemy_scene)
			enemy_scene.global_position = enemy_marker.global_position


func spawn_enemy_from_door():
	if !selected_door:
		selected_door = valid_spawn_door.keys()[0]
		selected_door.spawn_enemy()
		last_floor_spawned = selected_door.get_floor()
		return
	
	var selected_door_floor = selected_door.get_floor()
	if !valid_spawn_door.find_key(selected_door_floor -1):
		selected_door = valid_spawn_door.keys().get(randi_range(0, valid_spawn_door.size() - 1))
		
	else:	
		var selected_door_iterations = 0	
		var valid_door_array = valid_spawn_door.keys()
		while selected_door.get_floor() ==	last_floor_spawned:
		#randomly select a door from among the doors on screen, ask it to spawn enemy
			selected_door_iterations = selected_door_iterations + 1
			assert(selected_door_iterations < 30, "selecting door algorithm has iterated too many times")
			selected_door = valid_door_array.get(randi_range(0, valid_spawn_door.size() - 1))
	
	if enemy_count <= MAX_ENEMY_COUNT:
		last_floor_spawned = selected_door.get_floor()
		selected_door.spawn_enemy()
			
func spawn_door_hall():
	for door_hall_marker in level.get_children():
		if door_hall_marker is DoorHallMarker:
			var door_hall_scene: DoorHall = DOOR_HALL_SCENE.instantiate().set_player_door(door_hall_marker.player_door)
			if door_hall_scene.player_door:
				document_count = document_count + 1
			add_child(door_hall_scene)
			doors.append(door_hall_scene)
			door_hall_scene.global_position = door_hall_marker.global_position
			


func _got_document():
	document_count = document_count - 1
	hud.update_document_count(document_count)

func _player_changed_floor():
	valid_spawn_door.clear()
	for door in doors:
		if door.can_spawn_enemy():
			valid_spawn_door[door] = door.get_floor()
			
func _enemy_spawned():
	enemy_count = enemy_count + 1

func _enemy_despawned():
	enemy_count = enemy_count - 1
	
func _on_enemy_spawn_timer_timeout():
	spawn_enemy_from_door()
	enemy_spawn_timer.start()

func _player_died():
	retry_timer.start()
	

func _on_retry_timer_timeout() -> void:
	get_tree().reload_current_scene()
