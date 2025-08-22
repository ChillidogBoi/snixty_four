extends CharacterBody3D

var vulnerable = true
@export var hurt_box: Area3D
@export var anims: AnimationPlayer
@export var is_launcher = false
@export var plar: CharacterBody3D
@export var prompt: Sprite3D
var health = 50
const particle = [preload("res://scripts/particle.tscn"), preload("res://assets/particles/hay.png")]


func _ready():
	plar = get_parent().get_parent().plar

func _process(delta):
	if plar.global_position.distance_to(global_position) < 12:
		if prompt.visible != true: prompt.visible = true
		if Input.is_action_just_pressed("target"):
			plar.find_child("states").targeted = self
		if Input.is_action_just_released("target"):
			plar.find_child("states").targeted = null
	elif prompt.visible != false: prompt.visible = false


func _physics_process(delta):
	if vulnerable and hurt_box.get_overlapping_areas() != []:
		vulnerable = false
		for n in hurt_box.get_overlapping_areas():
			health -= n.damage
			for l:int in n.damage:
				var r = particle[0].instantiate()
				get_parent().add_child(r)
				r.global_position = (n.global_position + global_position)/2
				r.get_child(0).texture = particle[1]
				var x = randi_range(-1,1) * 14
				r.apply_central_impulse(Vector3(x, 2, 0))
				if x == 0: r.apply_central_impulse(Vector3(0, 14, 0))
				
			var flash = Vector3(global_position.x, n.global_position.y, global_position.z)
			n.find_child("hit").global_position = flash
			n.find_child("hit").visible = true
			await get_tree().create_timer(0.1).timeout
			n.find_child("hit").visible = false
		anims.play("hit")
		await anims.animation_finished
		vulnerable = true
		if health < 1:
			die()

func die():
	vulnerable = false
	anims.play("die")
	await get_tree().create_timer(5.0).timeout
	anims.play_backwards("die")
	health = 50
	vulnerable = true
