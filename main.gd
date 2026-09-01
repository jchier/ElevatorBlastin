extends Node

const PLAYER_SCENE: PackedScene = preload("uid://c2rgnnuoe4mpu")
const ENEMY_SCENE: PackedScene = preload("uid://bftk50lxpoojr")
const DOOR_HALL_SCENE: PackedScene = preload("uid://dmn4ui4jcf713")
const MAX_ENEMY_COUNT: int = 8
@export var level_one: PackedScene
@onready var retry_timer: Timer = $RetryTimer
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var hud: CanvasLayer = $Hud
@onready var main_menu_scene: PackedScene = load("uid://c3qu1tjmxrl3n")
@onready var ending_scene: PackedScene = load("uid://bbpx6qyly52fw")
@export var levels: Array

var level: Node
var document_count: int = 0
var doors: Array
var player_doors: Array
var valid_spawn_door: Dictionary[DoorHall, int]
var selected_door: DoorHall
var enemy_count: int
var last_floor_spawned: int
var win_detector_component: WinDetectorComponent
var player_spawn: PlayerMarker

func _ready():
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)
	_load_level()
	add_child(level)
	spawn_player()
	initialize_enemy_manager()
	spawn_door_hall()
	initialize_win_component()
	initialize_car()
	GameEvent.player_changed_floor.connect(_player_changed_floor)
	GameEvent.enemy_spawned.connect(_enemy_spawned)
	GameEvent.enemy_despawned.connect(_enemy_despawned)
	GameEvent.got_document.connect(_got_document)
	GameEvent.gameover.connect(_gameover)
	win_detector_component.check_win.connect(_check_win)
	hud.update_document_count(player_doors.size())
	hud.display_warning("Find all the documents in the red door,\nthen make your way to the bottom floor!")

func _load_level():
	level = load(levels[GameState.current_level]).instantiate()

func spawn_player():
	for player_marker in level.get_children():
		if player_marker is PlayerMarker:
			var player_scene: Player = PLAYER_SCENE.instantiate()
			add_child(player_scene)
			player_scene.global_position = player_marker.global_position
			player_scene.died.connect(_player_died)
			GameEvent.player_spawned.emit(player_scene)
			player_spawn = player_marker
			
func initialize_enemy_manager():
	for enemy_marker in level.get_children():
		if enemy_marker is EnemyMarker:
			enemy_manager.add_enemy_marker(enemy_marker)
			
	

func spawn_enemy_from_door():
	if !valid_spawn_door:
		return
		
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
			selected_door = valid_door_array.pick_random()
	
	if enemy_count <= MAX_ENEMY_COUNT:
		last_floor_spawned = selected_door.get_floor()
		selected_door.spawn_enemy()
			
func spawn_door_hall():
	for door_hall_marker in level.get_children():
		if door_hall_marker is DoorHallMarker:
			var door_hall_scene: DoorHall = DOOR_HALL_SCENE.instantiate().set_player_door(door_hall_marker.player_door)
			if door_hall_scene.player_door:
				#document_count = document_count + 1
				player_doors.append(door_hall_scene)
				#hud.update_document_count(player_doors.size())
			add_child(door_hall_scene)
			doors.append(door_hall_scene)
			door_hall_scene.global_position = door_hall_marker.global_position
			
func initialize_car():
	for car in level.get_children():
		if car is Car:
			car.drove_away.connect(_on_car_drove_away)


func initialize_win_component():
	for win_component in level.get_children():
		if win_component is WinDetectorComponent:
			win_detector_component = win_component
	assert(win_detector_component != null, "error: win detector component not initialized.")

func _got_document(door: DoorHall):
	player_doors.erase(door)
	hud.update_document_count(player_doors.size())
	hud.got_document()
	if player_doors.size() == 0:
		hud.display_warning("You got all the documents. \nMake your way to the exit!")
	player_spawn.global_position = door.global_position
	
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
	GameState.player.respawn(player_spawn.global_position)
	
func player_respawn():
	GameState.player.respawn(player_spawn.global_position)

func _gameover():
	get_tree().change_scene_to_packed(main_menu_scene)
	
func _check_win():
	if player_doors.size() > 0:
		hud.display_warning("There are still documents to find!\nGo in the red doors.")
		GameState.player.global_position = player_doors[0].global_position
		player_spawn.global_position = player_doors[0].global_position
		reset_physics_interpolation()
		Music.error()
	else:
		GameEvent.player_win.emit()
		
func _on_car_drove_away():
	GameEvent.advance_level.emit()
	get_tree().reload_current_scene()
