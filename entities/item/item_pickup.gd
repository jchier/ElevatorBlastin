@tool
class_name ItemPickup
extends Node2D
@onready var area_2d: Area2D = $Area2D

@export var item: Item:
	set(_item):
		item = _item
		update_sprite()

@onready var sprite: Sprite2D = $Sprite2D
var picked_up: bool = false


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
		Global.Item_Effect.GIVE_MG:
			player.get_mg()
			
	GameEvent.add_score.emit(item.points)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if picked_up:
		return
	if body is Player:
		picked_up = true
		use_item(body)
		sprite.queue_free()
		Music.item_get()
		queue_free()
