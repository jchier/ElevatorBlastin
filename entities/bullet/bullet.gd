class_name Bullet
extends Node2D

const SPEED: int = 50
var direction: float

@onready var life_timer: Timer = $LifeTimer
@onready var hitbox_component: HitboxComponent = $HitboxComponent

func _ready() -> void:
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	life_timer.timeout.connect(_on_life_timer_timeout)
	life_timer.start()

func _process(delta: float):
	global_position.x += direction * SPEED * delta

func start(dir: float):
	self.direction = dir

	
func _on_life_timer_timeout():
	queue_free()

func _on_hit_hurtbox(_hurtbox_component: HurtboxComponent):
	_register_collision()


func _register_collision():
	queue_free()
