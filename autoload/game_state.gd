extends Node

var player: Player
var docs_remaining: int
var score: int
var high_score: int
var current_level: int = 0
var starting_health: int = 3:
	set(value):
		if value < 3:
			starting_health = 3
		else:
			starting_health = value
			
var life_counter: int:
	set(value):
		life_counter = value
		GameEvent.player_lives_changed.emit(life_counter)
		
var ammo: int:
	set(value):
		ammo = value
		GameEvent.player_ammo_changed.emit(ammo)
		if ammo <= 0:
			player.has_machine_gun = false
	
		
var starting_score_threshold = {
	10000: "false",
	25000: "false",
	50000: "false",
	100000: "false"
}

var score_threshold = starting_score_threshold.duplicate()

func _ready():
	GameEvent.player_spawned.connect(_on_player_spawned)
	GameEvent.add_score.connect(_score_changed)
	GameEvent.advance_level.connect(_on_advanced_level)
	life_counter = Global.PLAYER_STARTING_LIVES
	score = 0
	
func _on_player_spawned(_player: Player):
	player = _player

func _got_document():
	docs_remaining = docs_remaining - 1
	
func _score_changed(points: int):
	score += points
	if score_threshold and score >= score_threshold.find_key("false"):
		var passed_score_threshold = score_threshold.find_key("false")
		score_threshold.erase(passed_score_threshold)
		player.life_up()
		Music.item_get()

func _on_advanced_level():
	current_level = current_level + 1

func _update_player_lives(lives: int):
	GameEvent.player_lives_changed.emit(lives)
	
func restart_game() -> void:
	score = 0
	ammo = Global.MAX_AMMO
	life_counter = Global.PLAYER_STARTING_LIVES
	starting_health = Global.PLAYER_STARTING_HEALTH
	score_threshold = starting_score_threshold.duplicate()
	current_level = 0
