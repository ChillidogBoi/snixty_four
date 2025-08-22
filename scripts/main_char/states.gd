extends Node

@export var health: int
@export var MAX_HEALTH:int

@export_category("Nodes")
@export var cur_state: Node
@export var last_state: Node
@export var camera_mover: Node
@export var hurt_box: Node
@export var dead: Node
@export var target: Node
@export var health_bar: TextureProgressBar

var vul = true
var targeted = null

func _physics_process(delta):
	cur_state.p_function(delta)
	
	if cur_state != last_state:
		last_state.e_function()
		cur_state.r_function()
		last_state = cur_state

func _process(delta):
	cur_state.function(delta)
	if not cur_state.cam_fixed and not targeted:
		camera_mover.run(delta)
	elif targeted and cur_state != target:
		target.last_state = cur_state
		target.enemy = targeted
		cur_state = target
	elif cur_state == target and not targeted:
		cur_state = cur_state.last_state
	
	
	# Hurt Player
	if cur_state.vulnerable and vul and hurt_box.get_overlapping_areas() != []:
		vul = false
		for n in hurt_box.get_overlapping_areas():
			health -= n.damage
			health_bar.value = (float(health)/float(MAX_HEALTH)) * 100
		if health < 1:
			cur_state = dead
			print(hurt_box.get_overlapping_areas()[0].death_message)
			health = MAX_HEALTH
		await get_tree().create_timer(0.2).timeout
		vul = true
	
	if Input.is_action_just_pressed("debug"):
		print(cur_state.name)
