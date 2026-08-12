extends MarginContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_scene: PackedScene = preload("uid://055g2w3ljnb1")
@onready var start_button: Button = %start_button


func _on_start_button_pressed() -> void:
	start_button.disabled = true
	animation_player.play(("fade_out"))

func load_main() -> void:
	get_tree().change_scene_to_packed(main_scene)
