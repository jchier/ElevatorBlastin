extends Node2D

func _ready():
	GameEvent.player_win.connect(_on_player_win)
	
	
func _on_player_win():
	GameState.player.win(global_position)
	
