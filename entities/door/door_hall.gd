class_name DoorHall
extends Node2D

signal document_get
const ENEMY_SCENE: PackedScene = preload("uid://bftk50lxpoojr")
const COLLISION_LAYER_VALUE: int = 19

@onready var interactive_component: InteractiveComponent = $InteractiveComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body_marker: Marker2D = $BodyMarker
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var floor_detector_component: FloorDetectorComponent = $FloorDetectorComponent
@onready var bulletproof: Area2D = $Bulletproof
@onready var dark_room_detector_component: Area2D = $DarkRoomDetectorComponent
@export var player_door: bool = false
@onready var sound_document_get: AudioStreamPlayer2D = $SoundDocumentGet
@onready var sound_door_open: AudioStreamPlayer2D = $SoundDoorOpen

var darkened: bool = false
var on_screen: bool = false
var player_has_entered: bool = false
var bullet_proof_disabled: bool:
	set(value):
		bulletproof.set_collision_layer_value(COLLISION_LAYER_VALUE, value)
	get():
		return bulletproof.get_collision_layer_value(COLLISION_LAYER_VALUE)



func set_player_door(is_player_door_: bool) -> DoorHall:
	player_door = is_player_door_
	return self

func _ready():	
	interactive_component.act.connect(_act)
	dark_room_detector_component.darken.connect(_darken)
	dark_room_detector_component.lighten.connect(_lighten)
	if player_door:
		sprite_2d.modulate = Color.CRIMSON
		

func _act(body: CharacterBody2D):
	if animation_player.current_animation == "open":
		body.start_interaction_animation("interaction_complete")
		return
	if body is Player and player_door:
		if player_has_entered:
			body.start_interaction_animation("interaction_complete")
			return
		player_act(body)
		player_has_entered = true
	elif body is Player and !player_door:
		body.start_interaction_animation("interaction_complete")
	elif body is Enemy:
		enemy_act(body)

func player_act(body: Player):
	#body.disabled = true
	
	var last_orientation: float = body.get_orientation() 
	body.set_orientation(1.0)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(body, "global_position", body_marker.global_position, 0.2)
	await tween.finished
	body.start_animation("enter")
	animation_player.play("open")
	await animation_player.animation_finished
	body.start_interaction_animation("exit")
	animation_player.play("open")
	await animation_player.animation_finished
	body.set_orientation(last_orientation)
	#body.disabled = false
	sound_document_get.play()
	GameEvent.got_document.emit(self)
	GameEvent.add_score.emit(Global.SCORE_GOT_DOCUMENT)
	
func enemy_act(body: Enemy):
	
	body.disabled = true
	body.set_orientation(1.0)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(body, "global_position", body_marker.global_position, 0.2)
	await tween.finished
	body.start_animation("enter")
	animation_player.play("open")
	await animation_player.animation_finished
	body.despawn()
	
	
func spawn_enemy():
	if animation_player.current_animation == "open":
		return
	var enemy_scene: Enemy = ENEMY_SCENE.instantiate()
	enemy_scene.darkened = darkened
	add_sibling(enemy_scene)
	enemy_scene.global_position = global_position
	enemy_scene.set_floor(get_floor())
	animation_player.play("open")
	await animation_player.animation_finished
	
	
func get_floor() -> int:
	return floor_detector_component.get_floor()

func can_spawn_enemy() -> bool:

	var value = GameState.player.get_floor() - get_floor()
	if value == 1 or value == 0:
			return true
	return false


func _darken():
	darkened = true
	sprite_2d.visible = false
	
func _lighten():
	darkened = false
	sprite_2d.visible = true

func toggle_bullet_proof():
	bullet_proof_disabled = !bullet_proof_disabled
