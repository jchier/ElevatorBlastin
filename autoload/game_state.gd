extends Node

var player: Player
var docs_remaining: int
var score: int
var high_score: int

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
