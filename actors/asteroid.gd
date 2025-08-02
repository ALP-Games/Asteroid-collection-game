class_name Asteroid extends RigidBody3D

const DEFAULT_SCALE := 1

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var asteroid_scale := 1

@export var weight_value_multiplier: float = 0.1
@export var default_density: float = 100.0

## Maybe works

func set_mass_with_scale(new_scale: float) -> void:
	var change := new_scale / asteroid_scale
	mesh_instance_3d.scale *= change
	collision_shape_3d.scale *= change
	asteroid_scale *= change
	mass = default_density * pow(new_scale, 3)


func get_asteroid_value() -> int:
	return mass * weight_value_multiplier
