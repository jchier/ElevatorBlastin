class_name HurtboxComponentSimple
extends Area2D

signal hit_by_hitbox

@export var health_component: HealthComponent
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _handle_hit(hitbox_component: Area2D):
	hitbox_component.register_hurtbox_hit(self)
	health_component.damage(hitbox_component.damage)
	hit_by_hitbox.emit()	
	
func _on_area_entered(other_area: Area2D):
	if other_area is not HitboxComponent:
		return

	_handle_hit(other_area)
