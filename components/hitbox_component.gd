class_name HitboxComponent
extends Area2D


signal hit_hurtbox(hurtbox_component: HurtboxComponent)
var damage: int = 1
var dir: int = 1
var has_hit: bool = true

func register_hurtbox_hit(hurtbox_component: HurtboxComponent):
	if !has_hit:
		hit_hurtbox.emit(hurtbox_component)
		has_hit = true
