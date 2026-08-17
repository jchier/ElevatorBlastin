extends Node

@onready var _music_idx: int = AudioServer.get_bus_index("music")
@onready var _sfx_idx: int = AudioServer.get_bus_index("sfx")

@onready var bg_music: AudioStreamPlayer = $BgMusic

func _ready():
	bg_music.finished.connect(_on_audio_stream_player_finished)
	GameEvent.player_died.connect(_on_player_died)
	GameEvent.player_spawned.connect(_on_player_spawned)


func _on_audio_stream_player_finished():
	bg_music.play()


func _on_player_died():
	bg_music.stop()


func _on_player_spawned(_player):
	bg_music.play()


func get_music_volume() -> float:
	return AudioServer.get_bus_volume_linear(_music_idx)


func set_music_volume(value: float) -> void:
	AudioServer.set_bus_volume_linear(_music_idx, value)


func get_sfx_volume() -> float:
	return AudioServer.get_bus_volume_linear(_sfx_idx)


func set_sfx_volume(value: float) -> void:
	AudioServer.set_bus_volume_linear(_sfx_idx, value)
