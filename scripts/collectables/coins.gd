@tool
extends Area3D
@export_enum("bag", "triple", "single") var amount = 0:
	set(v):
		amount = v
		change(v)
const vals = [20, 3, 1]
const type = "coin"
const use_style = "pickup"

@export var prompt: Sprite3D


func change(v):
	await ready
	for n in [$MeshInstance3D, $MeshInstance3D2, $MeshInstance3D3]: n.visible = false
	get_child(v).visible = true

func _physics_process(delta):
	rotate_y(0.005)
	if get_overlapping_areas() != [] and not prompt.visible:
		prompt.visible = true
	elif get_overlapping_areas() == [] and prompt.visible:
		prompt.visible = false
