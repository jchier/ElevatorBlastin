extends Node2D

var bullet_scene: PackedScene = preload("uid://rnaqg1ycr0e1")
@onready var bullet_marker_2d_stand: Marker2D = %BulletMarker2DStand
@onready var bullet_marker_2d_crouch: Marker2D = %BulletMarker2DCrouch
var crouch_toggled: bool = false
var direction: int = 1
func fire():
	var bullet = bullet_scene.instantiate() as Bullet
	get_parent().get_parent().add_child(bullet, true)
	if !crouch_toggled:
		bullet.global_position = bullet_marker_2d_stand.global_position
		bullet.start(direction)
	else:
		bullet.global_position = bullet_marker_2d_crouch.global_position
		bullet.start(direction)

	#TODO: fire rate timer, effects go here
	
func flip_horizontal(sign: float):
	scale.x = sign
	bullet_marker_2d_stand.rotation = sign
	bullet_marker_2d_crouch.rotation = sign
	direction = sign

func toggle_stance():
	crouch_toggled = !crouch_toggled
	
