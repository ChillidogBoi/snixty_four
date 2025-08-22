extends Node

@export var use: Area3D
@export var weap_hold: Node3D
@export var r_walk: Node
@export var t_walk: Node
@export var inv: Node
@export var coin_count: Label

const cam_fixed = false
const vulnerable = true

var talking = false


func r_function():
	pass


func function(delta):
	pass


func p_function(delta):
	var item = use.get_overlapping_areas()[0]
	if item.use_style == "pickup":
		if item.type == "sword":
			item.pickup(weap_hold, inv)
			get_parent().cur_state = t_walk
		if item.type == "coin":
			var cur = int(coin_count.text.get_slice(" ", 0))
			coin_count.text = str(cur + item.vals[item.amount], " x")
			item.queue_free()
			get_parent().cur_state = r_walk
	elif item.use_style == "talk" and not talking:
		talking = true
		item.talk()
		while not item.finished:
			await get_tree().create_timer(0).timeout
		get_parent().cur_state = r_walk


func e_function():
	await get_tree().create_timer(0.5).timeout
	talking = false
