@tool
extends Area3D

@export_multiline var text: String
@export_category("nodes")
@export var label_t: Node
@export var label_v: Node
@export var prompt: Sprite3D
@export var paper: MeshInstance3D
const use_style = "talk"
var finished = true


func _process(delta):
	if finished:
		if get_overlapping_areas() != [] and not prompt.visible:
			prompt.visible = true
		elif get_overlapping_areas() == [] and prompt.visible:
			prompt.visible = false


func talk():
	finished = false
	prompt.visible = false
	label_t.text = str("   ", text)
	label_v.visible = true
	await get_tree().create_timer(0.5).timeout
	while not Input.is_action_just_pressed("use"):
		await get_tree().create_timer(0).timeout
	label_v.visible = false
	finished = true
	await get_tree().create_timer(0.1).timeout
	prompt.visible = true
