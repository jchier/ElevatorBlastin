extends MarginContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_scene: PackedScene = preload("uid://055g2w3ljnb1")
@onready var start_button: Button = %start_button
@onready var level_select_container: HBoxContainer = %LevelSelectContainer

@onready var level_1_button: Button = %Level1Button
@onready var level_2_button: Button = %Level2Button
@onready var level_3_button: Button = %Level3Button


func _on_start_button_pressed() -> void:
	GameState.current_level = 0
	begin_game()

func load_main() -> void:
	get_tree().change_scene_to_packed(main_scene)

func begin_game() -> void:
	GameState.restart_game()
	animation_player.play(("fade_out"))

func _on_level_1_button_pressed() -> void:
	GameState.current_level = 0
	begin_game()

func _on_level_2_button_pressed() -> void:
	GameState.current_level = 1
	begin_game()
	
func _on_level_3_button_pressed() -> void:
	GameState.current_level = 2
	begin_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		level_select_container.visible = true
