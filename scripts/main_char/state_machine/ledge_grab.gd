extends Node


@export_category("Body")
@export var main: CharacterBody3D
@export var model: Node3D
@export var hurt_box: Area3D
@export var grab: RayCast3D
@export var eyes: RayCast3D
@export var right_hand: RayCast3D
@export var left_hand: RayCast3D

@export_category("Misc")
@export var climb_to: Node3D
@export var collider: CollisionShape3D
@export var anims: AnimationPlayer

@export_category("States")
@export var r_walk: Node
@export var anim_full: Node

const SPEED = 2.0
const cam_fixed = false
const vulnerable = true
var dir: Vector3
var snap_back: Vector3
var move_cool = true



func r_function():
	move_cool = true
	await get_tree().create_timer(0).timeout
	if not grab.is_colliding() or not main.is_on_wall():
		get_parent().cur_state = r_walk
	else:
		for n in ["left_leg", "right_leg"]:
			hurt_box.find_child(n).disabled = true
		main.velocity = Vector3.ZERO
		collider.shape.height = 1.8
	await get_tree().create_timer(0.5).timeout
	move_cool = false


func function(delta):
	pass


func p_function(delta):
	var input = Input.get_vector("east", "west", "north", "south")
	if move_cool: input = Vector2.ZERO
	var direction = model.transform.basis * Vector3(input.x, 0, input.y)
	
	
	
	if direction.x:
		var oldPos = eyes.get_collision_point()
		snap_back = oldPos
		var newPos
		
		if direction.x < -0.5 and right_hand.is_colliding():
			newPos = right_hand.get_collision_point()
		if direction.x > 0.5 and left_hand.is_colliding():
			newPos = left_hand.get_collision_point()
		else: main.velocity = Vector3.ZERO
		
		if newPos:
			main.velocity = (newPos - oldPos).normalized() * SPEED
			main.velocity.y = 0
			if not eyes.is_colliding():
				print("error")
		
		if direction.z > 0.5:
			model.rotate(Vector3.UP, PI)
			get_parent().cur_state = r_walk
		elif direction.z < -0.5:
			anim_full.cur_anim = 0
			get_parent().cur_state = anim_full
	else:
		main.velocity = Vector3.ZERO
		
		if direction.z > 0.5:
			model.rotate(Vector3.UP, PI)
			get_parent().cur_state = r_walk
		elif direction.z < -0.5:
			anim_full.cur_anim = 0
			get_parent().cur_state = anim_full
	
	if Input.is_action_just_pressed("jump") and not move_cool:
		anim_full.cur_anim = 0
		get_parent().cur_state = anim_full
	
	do_anims(direction)
	main.move_and_slide()


func do_anims(input):
	var offset_y_idle = 0.2
	var offset_y_move = 0.2
	
	if main.velocity:
		model.position.y = offset_y_move
		
		if input.x: anims.play("ledge_move")
		
	else:
		model.position.y = offset_y_idle
		anims.play("ledge_grab")


func e_function():
	move_cool = true
	r_walk.ledge_cool = true
	anims.play("idle")
	collider.shape.height = 2.8
	model.position.y = 0
	for n in ["left_leg", "right_leg"]:
		hurt_box.find_child(n).disabled = false
	await get_tree().create_timer(0.5).timeout
	r_walk.ledge_cool = false
