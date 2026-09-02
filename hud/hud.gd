extends Node
@onready var documents_label: Label = %DocumentsLabel
@onready var warning_label: Label = %WarningLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var heart_container: PanelContainer = %HeartContainer
@onready var heart_grid: GridContainer = %HeartGrid
@onready var lives_counter_label: Label = %LivesCounterLabel
@onready var machine_gun_container: HBoxContainer = %MachineGunContainer
@onready var ammo_counter_label: Label = %AmmoCounterLabel
@onready var score_label: Label = %ScoreLabel
@onready var heads_up_dialog: MarginContainer = $HeadsUpDialog
@onready var pause_menu: Control = %PauseMenu

const HEART = preload("uid://du4mn338cfknh")

var document_count: int = 0
		
func _ready():
	GameEvent.player_health_changed.connect(update_hearts)
	GameEvent.player_lives_changed.connect(update_lives)
	GameEvent.player_ammo_changed.connect(change_ammo)
	GameEvent.player_gun_changed.connect(gun_changed)
	GameEvent.add_score.connect(_score_changed)

func update_document_count(new_document_count: int):
	document_count = new_document_count
	documents_label.text = str("Documents Remaining: ", document_count)

func update_all():
	update_lives(GameState.life_counter)
	_score_changed(GameState.score)
	change_ammo(GameState.ammo)
	update_hearts(GameState.player.get_health())
	update_document_count(document_count)
	
func display_warning(warning_text):
	warning_label.text = warning_text
	animation_player.play("blink")

func update_hearts(health: int):
	for child in heart_grid.get_children():
		child.queue_free()
	
	while health > 0:
		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.texture = HEART
		heart_grid.add_child(texture_rect)
		health = health - 1

func update_lives(lives: int):
	lives_counter_label.text = str("x ", lives)

func gun_changed(has_mg: bool):
	machine_gun_container.visible = has_mg
	
func change_ammo(ammo: int):
	ammo_counter_label.text = str("x ", ammo)
	
func _score_changed(_points: int):
	score_label.text = str("Score: ", GameState.score)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if !pause_menu.visible:
			#heads_up_dialog.hide()
			pause_menu.show()
			get_tree().paused = true
		else:
			#heads_up_dialog.show()
			pause_menu.hide()
			get_tree().paused = false
		

func got_document():
	display_warning(str("You got a document! ", document_count, " documents remaining."))
