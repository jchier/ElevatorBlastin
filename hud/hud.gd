extends Node
@onready var documents_label: Label = $MarginContainer/VBoxContainer/DocumentsLabel

var document_count: int = 0

func _ready():
	update_document_count(document_count)

func update_document_count(new_document_count: int):
	document_count = new_document_count
	documents_label.text = str("Documents Remaining: ", document_count)
