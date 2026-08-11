extends Node

var player: Player
var docs_remaining: int


func _ready():
	GameEvent.player_spawned.connect(_on_player_spawned)
	
	
func _on_player_spawned(_player: Player):
	player = _player

func _got_document():
	docs_remaining = docs_remaining - 1
	
