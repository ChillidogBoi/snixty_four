extends Area3D

@export var weapon_name: String
@export var base_damage: int
@export var passive_damage: int
@export var damage: int
@export var knockback_trajectory: Vector3
@export var prompt: Sprite3D

const use_style = "pickup"
const type = "sword"

func pickup(to:Node3D, inv:Node):
	collision_layer = 4
	collision_mask = 4
	prompt.visible = false
	reparent(to)
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	inv.weapons.append(self)
