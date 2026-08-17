extends Node

var player: Player
var docs_remaining: int
var score: int
var high_score: int
var current_level: int = 0

var score_threshold = {
	10000: "false",
	25000: "false",
	50000: "false",
	100000: "false"
}
func _ready():
	GameEvent.player_spawned.connect(_on_player_spawned)
	GameEvent.add_score.connect(_score_changed)
	GameEvent.advance_level.connect(_on_advanced_level)
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

func _on_advanced_level():
	current_level = current_level + 1
