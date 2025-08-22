extends Node

@export_category("Nodes")
@export var wolf: CharacterBody3D
@export var view_a: Area3D
@export var view_d: Area3D
@export var nav: NavigationAgent3D
@export var anims: AnimationPlayer
@export var plar: CharacterBody3D
@export var chase: Node
@export var model: Node3D

var cooldown = true
var pause = false

func _ready():
	cooldown = false

func p_function(delta):
	if not wolf.is_on_floor():
		wolf.velocity = wolf.get_gravity()
	anims.play("idle")
	
	
	if not cooldown:
		cooldown = true
		if plar.global_position.distance_to(wolf.global_position) < 15:
			model.look_at(plar.global_position)
			if view_d.overlaps_body(plar):
				get_parent().cur_state = chase
		await get_tree().create_timer(0).timeout
		cooldown = false
