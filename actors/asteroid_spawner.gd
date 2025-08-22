class_name AsteroidSpawner extends Node3D

const ASTEROID_SCENE = preload("res://actors/asteroids/asteroid.tscn")
const ASTEROID_CRYSTAL_SCENE = preload("res://actors/asteroids/asteroid_crystal.tscn")
const ASTEROID_GOLD_SCENE = preload("res://actors/asteroids/asteroid_gold.tscn")

enum AsteroidType {
	NORMAL,
	CRYSTAL,
	GOLD
}

@export var spawn_radius: float = 400.0
@export var min_distance_between_asteroids: float = 10.0
# asteroid scale is actually a diameter
@export var asteroid_scale_max: float = 5.0
@export var asteroid_scale_min: float = 0.75
@export_group("Asteroid Crystal")
@export var crystal_minimum_distance: float = 75.0
@export_group("Asteroid Gold")
@export var gold_minimum_distance: float = 150.0
@export_group("Background")
@export var offset: Vector3 = Vector3.ZERO
@export var background_asteroid_count: int = 1000
@export var background_spawn_exponent: float = 0.65

@export var exclusion_zones: Array[RadiusNode3D]

var asteroid_count: int = 750

var thread := Thread.new()

func _rand_log_range(min_val: float, max_val: float, exponent: float = 0.55) -> float:
	var t := pow(randf(), exponent)
	return lerp(min_val, max_val, t)

func generate_non_overlapping_positions() -> Dictionary:
	# could do packed arrays for speed if needed
	var spawn_count: int = 0
	var positions: PackedVector3Array
	var radii: PackedFloat32Array
	var asteroid_types: PackedInt32Array
	
	positions.resize(asteroid_count)
	radii.resize(asteroid_count)
	asteroid_types.resize(asteroid_count)
	
	var return_dict: Dictionary = {
		"positions": positions,
		"radii": radii,
		"types": asteroid_types
	}
	var max_attempts := 1000
	while spawn_count < asteroid_count and max_attempts > 0:
		var radius := randf_range(asteroid_scale_min, asteroid_scale_max) / 2
		var log_range_val := _rand_log_range(0, spawn_radius)
		var pos := Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() * log_range_val
		var asteroid_type := AsteroidType.NORMAL
		
		var distance_from_center := pos.distance_to(global_position)
		if distance_from_center >= gold_minimum_distance:
			asteroid_type = randi_range(AsteroidType.NORMAL, AsteroidType.GOLD)
		elif distance_from_center >= crystal_minimum_distance:
			asteroid_type = randi_range(AsteroidType.NORMAL, AsteroidType.CRYSTAL)
	
		var valid := true
		for exclusion_zone in exclusion_zones:
			if pos.distance_to(exclusion_zone.global_position) < exclusion_zone.radius + radius:
				valid = false
				break
		
		if not valid:
			max_attempts -= 1
			continue
		
		for index in spawn_count:
			var other_pos := positions[index]
			var other_radius := radii[index]
			if pos.distance_to(other_pos) < other_radius + radius:
				valid = false
				break
		
		if not valid:
			max_attempts -= 1
			continue
		
		positions[spawn_count] = pos
		radii[spawn_count] = radius
		asteroid_types[spawn_count] = asteroid_type
		spawn_count += 1
	#print("Attempts left - ", max_attempts)
	return_dict["count"] = spawn_count
	return return_dict


# Maybe it doe not need to be "non overlaping"
func generate_non_overlaping_background() -> Dictionary:
	var spawn_count: int = 0
	var positions: PackedVector3Array
	var radii: PackedFloat32Array
	
	positions.resize(background_asteroid_count)
	radii.resize(background_asteroid_count)
	
	var return_dict: Dictionary = {
		"positions": positions,
		"radii": radii,
	}
	
	var max_attempts := 1000
	while spawn_count < background_asteroid_count and max_attempts > 0:
		var radius := randf_range(asteroid_scale_min, asteroid_scale_max) / 2
		var log_range_val := _rand_log_range(0, spawn_radius, background_spawn_exponent)
		var pos := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 0.0), randf_range(-1.0, 1.0)).normalized()\
			* log_range_val + offset
		
		var valid := true
		
		for index in spawn_count:
			var other_pos := positions[index]
			var other_radius := radii[index]
			if pos.distance_to(other_pos) < other_radius + radius:
				valid = false
				break
		
		if valid:
			positions[spawn_count] = pos
			radii[spawn_count] = radius
			spawn_count += 1
			continue
		
		max_attempts -= 1
	#print("Attempts left - ", max_attempts)
	return_dict["count"] = spawn_count
	return return_dict


func _generate_gameplay_asteroids() -> void:
	var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
	var return_dict := generate_non_overlapping_positions()
	var positions := return_dict["positions"] as PackedVector3Array
	var radii := return_dict["radii"] as PackedFloat32Array
	var asteroid_types := return_dict["types"] as PackedInt32Array
	var count := return_dict["count"] as int
	for index in count:
		var asteroid_instance: Asteroid
		match asteroid_types[index]:
			AsteroidType.NORMAL:
				asteroid_instance = ASTEROID_SCENE.instantiate()
			AsteroidType.CRYSTAL:
				asteroid_instance = ASTEROID_CRYSTAL_SCENE.instantiate()
			AsteroidType.GOLD:
				asteroid_instance = ASTEROID_GOLD_SCENE.instantiate()
		instantiated_root.add_child(asteroid_instance)
		asteroid_instance.global_position = positions[index]
		asteroid_instance.set_mass_with_scale(radii[index] * 2.0)


func _generate_background_asteroids() -> void:
	var multi_mesh_instance := MultiMeshInstance3D.new()
	var multi_mesh := MultiMesh.new()
	multi_mesh.mesh = preload("res://Assets/Icosphere_Icosphere_001.res")
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	#multi_mesh.color_array = MultiMesh.
	#multi_mesh.custom_data_array
	
	var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
	var return_dict := generate_non_overlaping_background()
	var positions := return_dict["positions"] as PackedVector3Array
	var radii := return_dict["radii"] as PackedFloat32Array
	var count := return_dict["count"] as int
	multi_mesh.instance_count = count
	for index in count:
		var xform = Transform3D()
		var scale_number := radii[index] / 2
		xform = xform.scaled(Vector3(scale_number, scale_number, scale_number))
		xform.basis = Basis(Vector3.UP, randf() * TAU)
		xform.origin = positions[index]
		multi_mesh.set_instance_transform(index, xform)
	
	multi_mesh_instance.multimesh = multi_mesh
	instantiated_root.add_child(multi_mesh_instance)


func _ready() -> void:
	_generate_gameplay_asteroids()
	_generate_background_asteroids()
