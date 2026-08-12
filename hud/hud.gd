extends Node
@onready var documents_label: Label = %DocumentsLabel
@onready var warning_label: Label = %WarningLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var document_count: int = 0
		
func _ready():
	update_document_count(document_count)
	

func update_document_count(new_document_count: int):
	document_count = new_document_count
	documents_label.text = str("Documents Remaining: ", document_count)

func display_warning(warning_text):
	warning_label.text = warning_text
	animation_player.play("blink")
