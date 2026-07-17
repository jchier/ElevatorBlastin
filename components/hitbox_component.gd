class_name HitboxComponent
extends Area2D


signal hit_hurtbox(hurtbox_component: HurtboxComponent)
signal hit_wall
var damage: int = 1

func wall_hit():
	hit_wall.emit

func register_hurtbox_hit(hurtbox_component: HurtboxComponent):
	hit_hurtbox.emit(hurtbox_component)
