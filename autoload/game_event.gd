extends Node

signal player_spawned(player: Player)
signal player_changed_floor
signal player_health_changed(health: int)
signal player_lives_changed(lives: int)
signal player_gun_changed(has_mg: bool)
signal player_ammo_changed(ammo: int)
signal player_died
signal enemy_spawned
signal enemy_despawned
signal got_document(door: DoorHall)
signal broken_lamp
signal gameover
signal add_score(points: int)
signal advance_level
