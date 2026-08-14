@tool
class_name ItemPickup
extends Node2D
@onready var area_2d: Area2D = $Area2D

@export var item: Item:
	set(_item):
		item = _item
		update_sprite()

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# bust cache for equipped items
	item = item.duplicate()
	update_sprite()

func update_sprite():
	if item and sprite:
		sprite.texture = item.texture
		
func use_item(player: Player):
	match item.effect:
		Global.Item_Effect.HEALTH_UP:
			player.health_up()
		Global.Item_Effect.LIFE_UP:
			player.life_up()
		


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		use_item(body)
		queue_free()
