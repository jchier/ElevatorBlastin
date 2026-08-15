class_name Lamp
extends Node2D

const DARK_ROOM_MASK_VALUE = 22
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var detect_floor_ray: RayCast2D = $DetectFloorRay
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dark_room_detector_component: Area2D = $DarkRoomDetectorComponent

var speed: int = 300
var floor_number: int = -1
var hit: bool
var direction: float = 1

func _ready():
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	
	set_physics_process(false)


	
func _physics_process(delta: float) -> void:
	global_position.y += direction * speed * delta


func _acquire_floor_number():
	detect_floor_ray.force_raycast_update()	
	var floor_marker: FloorMarkerComponent = detect_floor_ray.get_collider()
	floor_number = floor_marker.floor
	assert(floor_number != -1, "lamp could not determine floor number")
	
func _on_hit_hurtbox(hurtbox_component: HurtboxComponent):
	if hurtbox_component.is_in_group("enemy"):
		GameEvent.add_score.emit(Global.SCORE_LAMP_HIT_ENEMY)	
	_register_collision()

func _register_collision():
	hitbox_component.queue_free()
	GameEvent.broken_lamp.emit(self)
	speed = 0
	animation_player.play("break")



func _on_hurtbox_area_entered(_area: Area2D) -> void:
	set_physics_process(true)
	hurtbox.set_collision_mask_value(1, true)



func _on_hitbox_component_area_entered(area: Area2D) -> void:
	_register_collision()




func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		_register_collision()
