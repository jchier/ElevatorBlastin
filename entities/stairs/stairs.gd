class_name Stairs
extends Node2D

@onready var stairs_top_marker: Marker2D = $StairsTopMarker
@onready var stairs_bottom_marker: Marker2D = $StairsBottomMarker
@onready var stairs_top_area: Area2D = $StairsTopArea
@onready var stairs_bottom_area: Area2D = $StairsBottomArea



func _ready():
	stairs_top_area.act.connect(descend_body)
	stairs_bottom_area.act.connect(ascend_body)
	
func descend_body(body: CharacterBody2D):
	if !body:
		return
	move_body(stairs_top_marker.global_position, stairs_bottom_marker.global_position,\
	 body)

func ascend_body(body: CharacterBody2D):
	if !body:
		return
	move_body(stairs_bottom_marker.global_position, stairs_top_marker.global_position,\
	 body)

func move_body(starting_point: Vector2, destination: Vector2, body: CharacterBody2D):
	var old_z = body.z_index
	body.z_index = z_index - 10
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(body, "global_position", starting_point, 0.2)
	tween.tween_property(body, "global_position", destination, 1.0)
	await tween.finished
	body.z_index = old_z
	
