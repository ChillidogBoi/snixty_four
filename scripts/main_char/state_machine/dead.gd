extends Node

@export_category("Body")
@export var main: CharacterBody3D
@export var model: Node3D
@export var hurt_box: Area3D
@export var anims: AnimationPlayer

@export_category("Camera")
@export var cam: Camera3D
@export var cam_track: Node3D
@export var cam_ray: RayCast3D

@export_category("States")
@export var r_walk: Node

const cam_fixed = false
const vulnerable = false


func r_function():
	main.velocity = Vector3.ZERO
	anims.stop()
	for t:int in 6:
		await get_tree().create_timer(0.1).timeout
		model.visible = false
		await get_tree().create_timer(0.1).timeout
		model.visible = true
	
	main.global_position = main.get_parent().spawn
	main.global_rotation.y = main.get_parent().spawn_rot
	cam.global_position = cam_track.global_position  + Vector3(0, 0.5, 0)
	model.rotation.y = 0
	cam.look_at(model.global_position + Vector3(0, 2.5, 0))
	
	await get_tree().create_timer(0).timeout # important
	
	get_parent().health_bar.value = (float(get_parent().health)/float(get_parent().MAX_HEALTH)) * 100
	get_parent().cur_state = r_walk
	get_parent().health = get_parent().MAX_HEALTH


func function(delta):
	pass


func p_function(delta):
	pass


func e_function():
	pass
