extends Control

@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var quit_to_main_button: Button = %QuitToMainButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_to_main_button.pressed.connect(_on_quit_to_main_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	music_volume_slider.value_changed.connect(_music_volume_value_changed)
	sfx_volume_slider.value_changed.connect(_sfx_volume_value_changed)
	
	music_volume_slider.value = Music.get_music_volume()
	sfx_volume_slider.value = Music.get_sfx_volume()





func _on_resume_button_pressed():
	hide()
	get_tree().paused = false


func _on_quit_to_main_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func _music_volume_value_changed(value: float):
	Music.set_music_volume(value)


func _sfx_volume_value_changed(value: float):
	Music.set_sfx_volume(value)
