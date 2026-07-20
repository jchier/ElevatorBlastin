extends Node

var player: Player


func _ready():
	GameEvent.player_spawned.connect(_on_player_spawned)
	
	
func _on_player_spawned(_player: Player):
	player = _player
