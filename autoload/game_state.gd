extends Node

var player: Player
var docs_remaining: int
var score: int
var high_score: int

var score_threshold = {
	10000: "false",
	25000: "false",
	50000: "false",
	100000: "false"
}
func _ready():
	GameEvent.player_spawned.connect(_on_player_spawned)
	GameEvent.add_score.connect(_score_changed)
	score = 0
	
func _on_player_spawned(_player: Player):
	player = _player

func _got_document():
	docs_remaining = docs_remaining - 1
	
func _score_changed(points: int):
	score += points
	print(score_threshold.find_key("false"))
	if score_threshold and score >= score_threshold.find_key("false"):
		var passed_score_threshold = score_threshold.find_key("false")
		score_threshold.erase(passed_score_threshold)
		player.life_up()
