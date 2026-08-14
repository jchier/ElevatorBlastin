extends Node
@onready var documents_label: Label = %DocumentsLabel
@onready var warning_label: Label = %WarningLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var heart_container: PanelContainer = %HeartContainer
@onready var heart_grid: GridContainer = %HeartGrid
@onready var lives_counter_label: Label = %LivesCounterLabel

const HEART = preload("uid://du4mn338cfknh")

var document_count: int = 0
		
func _ready():
	update_document_count(document_count)
	GameEvent.player_health_changed.connect(update_hearts)
	GameEvent.player_lives_changed.connect(update_lives)

func update_document_count(new_document_count: int):
	document_count = new_document_count
	documents_label.text = str("Documents Remaining: ", document_count)

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
