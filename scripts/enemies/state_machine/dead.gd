extends Node
var anim_fin = false
var plar

@export var wolf: CharacterBody3D
@export var anims: AnimationPlayer
var pause = false


func p_function(delta):
	if not anim_fin:
		anim_fin = true
		plar.find_child("states").targeted = null
		anims.play("die")
		await get_tree().create_timer(2).timeout
		wolf.queue_free()
