class_name Bullet
extends Node2D

const SPEED: int = 500
var direction: float = 1.0

@onready var life_timer: Timer = $LifeTimer
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@export var points: int

func _ready() -> void:
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	life_timer.timeout.connect(_on_life_timer_timeout)
	life_timer.start()

func _process(delta: float):
	global_position.x += direction * SPEED * delta

func start(dir: float):
	self.direction = dir
	hitbox_component.dir = dir
	
func _on_life_timer_timeout():
	queue_free()

func _on_hit_hurtbox(_hurtbox_component: HurtboxComponent):
	GameEvent.add_score.emit(points)
	_register_collision()



func _register_collision():
	queue_free()



func _on_hitbox_component_area_entered(_area: Area2D) -> void:
	_register_collision()


func _on_hitbox_component_body_entered(body: Node2D) -> void:
	if body is TileMapLayer or body is StaticBody2D:
		_register_collision()
