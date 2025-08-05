class_name Asteroid extends RigidBody3D

const ROCK_EXPLOSION = preload("res://Assets/vfx/RockExplosion.tscn")
const ASTEROID_CRUNCH_SOUND = preload("res://actors/asteroid_crunch_sound.tscn")

const DEFAULT_SCALE := 1

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var asteroid_scale := 1

@export var weight_value_multiplier: float = 0.1
@export var default_density: float = 100.0

var init_on_ready := false
## Maybe works

func _ready() -> void:
	if not init_on_ready:
		return
	var change := asteroid_scale / DEFAULT_SCALE
	mesh_instance_3d.scale *= change
	collision_shape_3d.scale *= change

func set_mass_with_scale(new_scale: float) -> void:
	var change := new_scale / asteroid_scale
	if is_node_ready():
		mesh_instance_3d.scale *= change
		collision_shape_3d.scale *= change
	else:
		init_on_ready = true
	asteroid_scale *= change
	mass = default_density * pow(new_scale, 3)


func get_asteroid_value() -> int:
	return mass * weight_value_multiplier


func destroy_asteroid() -> void:
	var destroy_effect := ROCK_EXPLOSION.instantiate()
	get_tree().get_first_node_in_group("instantiated_root").add_child(destroy_effect)
	destroy_effect.global_position = global_position
	var particles := destroy_effect.get_child(0) as GPUParticles3D
	particles.emitting = true
	particles.finished.connect(func():destroy_effect.queue_free())
	
	var destroy_sound := ASTEROID_CRUNCH_SOUND.instantiate() as AudioStreamPlayer3D
	get_tree().get_first_node_in_group("instantiated_root").add_child(destroy_sound)
	destroy_sound.global_position = global_position
	destroy_sound.finished.connect(func():destroy_sound.queue_free())
	queue_free()
