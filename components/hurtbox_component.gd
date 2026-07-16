class_name HurtboxComponent
extends Area2D

signal hit_by_hitbox

@export var health_component: HealthComponent
@onready var standing_collision_shape: CollisionShape2D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape2D = $CrouchingCollisionShape
@onready var airborne_collision_shape: CollisionShape2D = $AirborneCollisionShape

var last_grounded_collision_shape: CollisionShape2D
var disabled: bool:
	set(value):
		crouching_collision_shape.set_deferred("disabled", value)
		standing_collision_shape.set_deferred("disabled", value)
		airborne_collision_shape.set_deferred("disabled", value)
		disabled = value

func _ready() -> void:
	last_grounded_collision_shape = standing_collision_shape
	crouching_collision_shape.disabled = true
	airborne_collision_shape.disabled = true
	area_entered.connect(_on_area_entered)
	
func _handle_hit(hitbox_component: Area2D):
	hitbox_component.register_hurtbox_hit(self)
	health_component.damage(hitbox_component.damage)
	hit_by_hitbox.emit()	
	
func _on_area_entered(other_area: Area2D):
	if other_area is not HitboxComponent:
		return

	_handle_hit(other_area)

func toggle_stance():
	if !standing_collision_shape.disabled and crouching_collision_shape.disabled:
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		last_grounded_collision_shape = crouching_collision_shape
	elif standing_collision_shape.disabled and !crouching_collision_shape.disabled:
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		last_grounded_collision_shape = standing_collision_shape

func toggle_airborne():
	if airborne_collision_shape.disabled == true:
		airborne_collision_shape.disabled = false
		last_grounded_collision_shape.disabled = true
		
	else:
		airborne_collision_shape.disabled = true
		last_grounded_collision_shape.disabled = false
