extends Node

@export_category("Body")
@export var main: CharacterBody3D
@export var model: Node3D
@export var head: MeshInstance3D
@export var hurt_box: Area3D
@export var use_area: Area3D
@export var weap: Node3D
@export var hand: MeshInstance3D

@export_category("Misc.")
@export var cyote: RayCast3D
@export var buffer: RayCast3D
@export var anims: AnimationPlayer
@export var cam_track: Node3D

@export_category("States")
@export var r_walk: Node
@export var use: Node
@export var cam_turn: Node

const BASE_SPEED = 8.0
const JUMP_VELOCITY = 9.5
const cam_fixed = false
const vulnerable = true

var grav: Vector3 = Vector3.DOWN
var speed = BASE_SPEED
var jumping = false
var ledge_cool = false
var hold_weap = false
var last_attack = 0
var attack_timer = null


func r_function(): # ready
	hold_weap = false
	grav = Vector3.DOWN
	anims.play("weap_ready")
	await get_tree().create_timer(0.2).timeout
	hold_weap = true
	

func e_function(): # exit
	weap.get_child(0).damage = 0
	weap.get_child(0).find_child("swoop").visible = false
	anims.stop()
	speed = BASE_SPEED
	jumping = false
	grav = Vector3.DOWN
	anims.play_backwards("weap_ready")
	var t = get_tree().create_timer(0.2)
	while t.time_left > 0:
		weap.global_position = hand.global_position
		weap.position += Vector3(0.1, 0.2, -0.3)
		weap.global_rotation = hand.global_rotation + Vector3(0, -PI/2, 0)
		await get_tree().create_timer(0).timeout
	hold_weap = false
	weap.position = Vector3(0.15, 2.2, 0.3)
	weap.rotation_degrees = Vector3(-75, 90, -90)


func function(delta): # process
	if Input.is_action_pressed("south"):
		if cam_track.position.z == 5: cam_track.position.z = 9
	elif cam_track.position.z == 9: cam_track.position.z = 5
	
	if Input.is_action_just_pressed("use"):
		if use_area.get_overlapping_areas() != []:
			get_parent().cur_state = use
		else: get_parent().cur_state = r_walk
	
	if attack_timer is SceneTreeTimer:
		if attack_timer.time_left == 0:
			anims.play("weap_idle")
			attack_timer = false
	
	if hold_weap:
		weap.global_position = hand.global_position
		weap.position += Vector3(0.1, 0, 0)
		weap.global_rotation = hand.global_rotation


func p_function(delta): # phys process
	hurt_box.find_child("head").global_position = head.global_position + Vector3(0, 0.05, 0.04)
	
	if not grav: grav = main.get_gravity() * delta
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
			weap.get_child(0).damage = weap.get_child(0).passive_damage
			anims.play("weap_idle")
		if anims.current_animation == "weap_idle":
			weap.get_child(0).damage = weap.get_child(0).passive_damage
	
	if Input.is_action_just_pressed("attack"):
		if direction: attack_lunge()
		else: attack_still()
	if anims.current_animation == "run_2":
		weap.get_child(0).damage = weap.get_child(0).passive_damage
		weap.get_child(0).find_child("swoop").visible = false
	elif anims.current_animation == "weap_idle":
		weap.get_child(0).damage = weap.get_child(0).passive_damage
		weap.get_child(0).find_child("swoop").visible = false
	elif anims.current_animation == "weap_ready":
		weap.get_child(0).damage = weap.get_child(0).passive_damage
		weap.get_child(0).find_child("swoop").visible = false
	elif not anims.is_playing():
		weap.get_child(0).damage = weap.get_child(0).passive_damage
		weap.get_child(0).find_child("swoop").visible = false
	else:
		weap.get_child(0).damage = weap.get_child(0).base_damage
		weap.get_child(0).find_child("swoop").visible = true
	
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
		main.velocity.y = JUMP_VELOCITY
		if direction:
			grav = main.get_gravity() * delta * 4
			speed *= 1.25
			main.velocity.y = JUMP_VELOCITY
			await get_tree().create_timer(0).timeout
			while not main.is_on_floor():
				await get_tree().create_timer(0).timeout
			speed /= 1.25
		else:
			grav = main.get_gravity() * delta * 5
			speed /= 1.25
			main.velocity.y = JUMP_VELOCITY * 1.5
			await get_tree().create_timer(0).timeout
			while not main.is_on_floor():
				await get_tree().create_timer(0).timeout
			speed *= 1.25
		jumping = false


func attack_still():
	var att_six = last_attack
	if attack_timer is SceneTreeTimer:
		if attack_timer.time_left < 0.2 and attack_timer.time_left > 0:
			if last_attack == 0:
				last_attack = 1
				anims.play("attack_1")
			elif last_attack == 1:
				last_attack = 2
				anims.play("attack_2")
			elif last_attack == 2:
				last_attack = 3
				anims.play("attack_3")
			elif last_attack == 3:
				last_attack = 0
				anims.play("attack_reset")
		elif attack_timer.time_left == 0:
			anims.play("weap_idle")
	else:
		if att_six == 1: att_six = 0
		last_attack = 1
		anims.play("attack_1")
		print(attack_timer)
	
	if att_six != last_attack:
		attack_timer = get_tree().create_timer(0.5)


func attack_lunge():
	if not ["attack_lunge_1","attack_lunge_2"].has(anims.current_animation):
		anims.play(["attack_lunge_1","attack_lunge_2"][randi_range(0,1)])


func animate(a):
	if a == "run" and not ["attack_lunge_1","attack_lunge_2"].has(anims.current_animation):
		anims.play("run_2")
		if not main.is_on_floor():
			if anims.speed_scale != 0.25: anims.speed_scale = 0.25
		else:
			if anims.speed_scale == 0.25: anims.speed_scale = 1.175
