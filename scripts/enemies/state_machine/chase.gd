extends Node


@export var search: Node

@export_category("Movement")
@export var speed = 2
@export var accel = 10
@export var turn_speed = 4
@export var view_a: Area3D
@export var view_d: Area3D
@export var plar: CharacterBody3D
@export var nav: NavigationAgent3D

@export_category("Body")
@export var wolf: CharacterBody3D
@export var claws: Area3D
@export var model: Node3D
@export var anims: AnimationPlayer
@export var point: Node3D

var hit_cool = false
var time_til_lost = null
var pause = false


func p_function(delta):
	var x = Vector3(plar.global_position.x, model.global_position.y, plar.global_position.z)
	point.look_at(x)
	model.rotation.y = lerp_angle(model.rotation.y, point.rotation.y, delta * turn_speed)
	anims.play("run")
	
	if view_a.overlaps_body(plar) and not pause:
		var direction = Vector3.ZERO
		nav.target_position = plar.global_position
		direction = nav.get_next_path_position() - wolf.global_position
		direction = direction.normalized()
		wolf.velocity = wolf.velocity.lerp(direction * speed, accel * delta)
		wolf.move_and_slide()
		
		if not hit_cool:
			hit_cool = true
			claws.damage = claws.base_damage
			await get_tree().create_timer(0.2).timeout
			claws.damage = claws.passive_damage
			await get_tree().create_timer(0.5).timeout
			hit_cool = false
	elif pause: wolf.move_and_slide()
	elif not view_a.overlaps_body(plar):
		get_parent().cur_state = search
		plar.find_child("states").targeted = null
		time_til_lost = null
	
