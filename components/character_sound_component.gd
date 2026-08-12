extends Node

@onready var shoot_sfx: AudioStreamPlayer2D = $shoot
@onready var hit_sfx: AudioStreamPlayer2D = $hit
@onready var jump_sfx: AudioStreamPlayer2D = $jump

func jump():
	jump_sfx.play()
	
func hit():
	hit_sfx.play()
	
func shoot():
	shoot_sfx.play()
	
	
	
