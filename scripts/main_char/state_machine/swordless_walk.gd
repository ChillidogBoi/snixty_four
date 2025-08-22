extends Node

@export_category("Body")
@export var main: CharacterBody3D
@export var model: Node3D
@export var head: MeshInstance3D
@export var hurt_box: Area3D
@export var use_area: Area3D
@export var weap: Node3D

@export_category("Misc.")
@export var grab: RayCast3D
@export var eyes: RayCast3D
@export var cyote: RayCast3D
@export var buffer: RayCast3D
@export var anims: AnimationPlayer
@export var cam_track: Node3D

@export_category("States")
@export var ledge_grab: Node
@export var cam_turn: Node
@export var threat: Node
@export var use: Node

const BASE_SPEED = 8.0
const JUMP_VELOCITY = 9.5
const cam_fixed = false
const vulnerable = true

var grav: Vector3 = Vector3.DOWN
var speed = BASE_SPEED
var jumping = false
var ledge_cool = false


func r_function(): # ready
	grav = Vector3.DOWN

func e_function(): # exit
	anims.stop()
	speed = BASE_SPEED
	jumping = false
	grav = Vector3.DOWN


func function(delta): # process
	if Input.is_action_pressed("south"):
		if cam_track.position.z == 5: cam_track.position.z = 9
	elif cam_track.position.z == 9: cam_track.position.z = 5
	
	if Input.is_action_just_pressed("attack") and weap.get_children() != []:
		get_parent().cur_state = threat
	if Input.is_action_just_pressed("use") and use_area.get_overlapping_areas() != []:
		get_parent().cur_state = use


func p_function(delta): # phys process
	hurt_box.find_child("head").global_position = head.global_position + Vector3(0, 0.05, 0.04)
	
	if not grav: grav = main.get_gravity() * delta
	if main.is_on_wall_only() and main.velocity.y < 0:
		grav = main.get_gravity() * delta / 3
	elif grav < main.get_gravity() * delta / 2 and not jumping:
		grav = main.get_gravity() * delta
	if not main.is_on_floor():
		main.velocity += grav
	
	var input_dir = Input.get_vector("west", "east", "north", "south")
	var direction = (main.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		cam_turn.cur_mt = direction
		main.velocity.x = direction.x * speed
		main.velocity.z = direction.z * speed
		animate("run")
	else:
		main.velocity.x = 0
		main.velocity.z = 0
		if anims.current_animation == "run_2":
			anims.play("idle")
	
	if Input.is_action_just_pressed("jump"):
		if main.is_on_floor() or cyote.is_colliding():
			jump(direction, delta)
		elif buffer.is_colliding():
			while not main.is_on_floor():
				await get_tree().create_timer(0).timeout
			jump(direction, delta)
	
	main.move_and_slide()


func jump(direction, delta):
	if not jumping:
		jumping = true
		animate("jump")
		main.velocity.y = JUMP_VELOCITY
		if direction:
			grav = main.get_gravity() * delta * 4
			speed *= 1.25
			main.velocity.y = JUMP_VELOCITY
			await get_tree().create_timer(0).timeout
			while not main.is_on_floor():
				await get_tree().create_timer(0).timeout
				if grab.is_colliding() and eyes.is_colliding() and not ledge_cool:
					grav = Vector3.ZERO
					main.velocity = Vector3.ZERO
					get_parent().cur_state = ledge_grab
			speed /= 1.25
		else:
			grav = main.get_gravity() * delta * 5
			speed /= 1.25
			main.velocity.y = JUMP_VELOCITY * 1.5
			await get_tree().create_timer(0).timeout
			while not main.is_on_floor():
				await get_tree().create_timer(0).timeout
				if grab.is_colliding() and eyes.is_colliding() and not ledge_cool:
					grav = Vector3.ZERO
					main.velocity = Vector3.ZERO
					get_parent().cur_state = ledge_grab
			speed *= 1.25
		jumping = false





func animate(a):
	if a == "run":
		anims.play("run_2")
		if not main.is_on_floor():
			if anims.speed_scale != 0.25: anims.speed_scale = 0.25
		else:
			if anims.speed_scale == 0.25: anims.speed_scale = 1.175
	elif a == "jump":
		anims.speed_scale = 1
		anims.play("jump")
		await get_tree().create_timer(anims.current_animation_length - 0.01).timeout
		anims.pause()
		while not main.is_on_floor(): await get_tree().create_timer(0).timeout
		if anims.current_animation != "idle" and anims.current_animation != "run":
			anims.play_backwards("jump", -2)
			
