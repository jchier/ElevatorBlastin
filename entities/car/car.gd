class_name Car
extends Node2D
var player: Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var car_sfx: AudioStreamPlayer2D = $CarSFX
signal drove_away

func _ready():

	GameEvent.player_win.connect(_on_player_win)
func _on_player_win():
	player = GameState.player
	player.win()
	player.set_orientation(signf(player.global_position.direction_to(global_position).x))

	var tween1 := create_tween()
	tween1.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween1.tween_property(player.camera_2d, "global_position", global_position, 1.0)
	var tween2 := create_tween()
	player.animation_component.play_direct("walk")
	tween2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween2.tween_property(player, "global_position", Vector2(global_position.x, player.global_position.y), 2.0)
	await tween2.finished
	player.animation_component.play_direct("enter_car")
	animation_player.play("player_enter")
	
func drive_away():
	#var tween := create_tween()
	#tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	animation_player.play("drive")
	#tween.tween_property(self, "global_position", Vector2(global_position.x - 10000, global_position.y), 50.0)	
	#audio.play()

func on_driven_away():
	drove_away.emit()
