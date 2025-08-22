extends Node

@export var r_walk: Node

@export_category("Body")
@export var main: CharacterBody3D
@export var model: Node3D
@export var hurt_box: Area3D
@export var anims: AnimationPlayer
@export var clim_to: Node3D

const cam_fixed = false
const vulnerable = true
const anim_list = ["climb_ledge"]
var cur_anim = 0
var debug = null

func r_function():
	if anim_list[cur_anim] == "climb_ledge":
		debug = get_tree().create_timer(0.5)
		anims.speed_scale = 1
		anims.play("ledge_vault")
		await get_tree().create_timer(0.1).timeout
		var targ = clim_to.global_position
		main.velocity.y = 20
		while not main.global_position.y > targ.y and debug.time_left > 0.01:
			main.move_and_slide()
			await get_tree().create_timer(0).timeout
		main.velocity = main.global_position.direction_to(targ) * 10
		while not main.global_position.distance_to(targ) < 0.5 and debug.time_left > 0.01:
			main.move_and_slide()
			await get_tree().create_timer(0).timeout
		get_parent().cur_state = r_walk


func function(delta):
	pass


func p_function(delta):
	pass


func e_function():
	pass
