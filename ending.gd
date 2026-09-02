extends MarginContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_menu_scene: PackedScene = preload("uid://c3qu1tjmxrl3n")
@onready var main_menu_button: Button = %main_menu_button
@onready var score_label: Label = %score_label

func _ready():
	score_label.text = str("score: ", GameState.score)


func load_main() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_main_menu_button_pressed() -> void:
	GameState.restart_game()
	main_menu_button.disabled = true
	animation_player.play(("fade_out"))
