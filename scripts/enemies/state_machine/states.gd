extends Node

@export var plar: CharacterBody3D

@export var health: int
@export var MAX_HEALTH:int

@export var wolf: CharacterBody3D
@export var model: Node3D
@export var cur_state: Node
@export var hurt_box: Area3D
@export var dead: Node
@export var prompt: Sprite3D

var vulnerable = true
const particle = [preload("res://scripts/particle.tscn"), preload("res://assets/particles/hay.png")]


func _ready():
	plar = get_parent().get_parent().get_parent().plar
	for c in get_children(): c.plar = plar

func _physics_process(delta):
	cur_state.p_function(delta)
	
	if plar.global_position.distance_to(wolf.global_position) < 12:
		if prompt.visible != true: prompt.visible = true
		if Input.is_action_just_pressed("target"):
			plar.find_child("states").targeted = wolf
		if Input.is_action_just_released("target"):
			plar.find_child("states").targeted = null
	elif prompt.visible != false: prompt.visible = false
	
func _process(delta): # Hurt Wolfy
	if vulnerable and hurt_box.get_overlapping_areas() != [] and cur_state != dead:
		vulnerable = false
		for n in hurt_box.get_overlapping_areas():
			health -= n.damage
			cur_state.pause = true
			wolf.velocity = n.knockback_trajectory.rotated(Vector3.UP, model.rotation.y)
			var flash = Vector3(wolf.global_position.x, n.global_position.y, wolf.global_position.z)
			n.find_child("hit").global_position = flash
			n.find_child("hit").visible = true
			await get_tree().create_timer(0.1).timeout
			n.find_child("hit").visible = false
		if health < 1:
			cur_state = dead
		cur_state.pause = false
		vulnerable = true
