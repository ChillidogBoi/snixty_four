extends Node

@export_category("Body")
@export var main: CharacterBody3D
@export var model: Node3D
@export var head: MeshInstance3D

@export_category("Camera")
@export var cam: Camera3D
@export var cam_track: Node3D
@export var cam_ray: RayCast3D
@export var cam_ray_left: RayCast3D

const TURN_SPEED = 5.0

var cur_mt: Vector3 = Vector3.ZERO
var look_dir_a: Vector3 = Vector3.ZERO
var cam_face: float = 0.0
var hold_mod: Vector3 = Vector3.ZERO
var fixing_cam = false
var con_model = true



func run(delta):
	if Input.is_action_just_pressed("target"): target(delta, true)
	
	target(delta, false)
	if con_model: model_look(delta)
	cam_look(delta)
	
	if not fixing_cam:
		cam_fix()


func cam_fix():
	fixing_cam = true
	cam_ray.global_rotation_degrees = Vector3(0,0,0)
	cam_ray.target_position = head.global_position - cam_ray.global_position
	cam_ray_left.target_position = head.global_position - cam_ray_left.global_position
	if cam_ray.is_colliding():
		if cam_ray.get_collider() != main:
			if cam_ray_left.is_colliding():
				if cam_ray_left.get_collider() != main:
					while cam_ray.get_collider() != main:
						cam_face += deg_to_rad(1)
						await get_tree().create_timer(0).timeout
				else:
					while cam_ray.get_collider() != main:
						cam_face -= deg_to_rad(1)
						await get_tree().create_timer(0).timeout
			else: 
				while cam_ray.get_collider() != main:
					await get_tree().create_timer(0).timeout
					cam_face -= deg_to_rad(1)
			cam_face = main.global_rotation.y
	fixing_cam = false

func target(delta:float, pressed:bool):
	if pressed:
		if abs(main.global_rotation.y - model.global_rotation.y) > deg_to_rad(1):
			hold_mod = model.global_rotation
			cam_face = model.global_rotation.y
	elif abs(main.global_rotation.y - model.global_rotation.y) > deg_to_rad(1):
		main.global_rotation.y = lerp_angle(main.global_rotation.y, cam_face, TURN_SPEED * delta)
		model.global_rotation = hold_mod

func cam_look(delta):
	if cam.global_position.distance_to(cam_track.global_position) > 0.01:
		cam.global_position = cam.global_position.slerp(cam_track.global_position, TURN_SPEED * delta)
	else: cam.global_position = cam_track.global_position
	cam.look_at(model.global_position + look_dir_a + Vector3(0, 2, 0))

func model_look(delta):
	if look_dir_a.distance_to(cur_mt) > 0.02:
		look_dir_a = look_dir_a.slerp(cur_mt, TURN_SPEED * delta)
	else: look_dir_a = cur_mt
	if look_dir_a != Vector3.ZERO:
		model.look_at(model.global_position + look_dir_a * 10)
