class_name AsteroidSpawner extends Node3D

const ASTEROID_SCENE = preload("res://actors/asteroid.tscn")

@export var spawn_radius: float = 250.0
@export var min_distance_between_asteroids: float = 10.0
# asteroid scale is actually a diameter
@export var asteroid_scale_max: float = 5.0
@export var asteroid_scale_min: float = 0.5
@export var spawn_interval_max: float = 5.0
@export var spawn_interval_min: float = 0.5

@export var exclusion_zones: Array[RadiusNode3D]

var asteroid_count: int = 200

func generate_non_overlapping_positions() -> Dictionary:
	# could do packed arrays for speed if needed
	var positions: Array[Vector3] = []
	var radii: Array[float] = []
	var return_dict: Dictionary = {
		"positions": positions,
		"radii": radii
	}
	var max_attempts := 1000
	while positions.size() < asteroid_count and max_attempts > 0:
		var radius := randf_range(asteroid_scale_min, asteroid_scale_max) / 2
		var pos := Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() * randf_range(0, spawn_radius)
	
		var valid := true
		for exclusion_zone in exclusion_zones:
			if pos.distance_to(exclusion_zone.global_position) < exclusion_zone.radius + radius:
				valid = false
				break
		
		if not valid:
			max_attempts -= 1
			continue
		
		for index in positions.size():
			var other_pos := positions[index]
			var other_radius := radii[index]
			if pos.distance_to(other_pos) < other_radius + radius:
				valid = false
				break
		
		if not valid:
			max_attempts -= 1
			continue
		
		positions.append(pos)
		radii.append(radius)
	print("Attempts left - ", max_attempts)
	return return_dict


func _ready() -> void:
	var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
	var return_dict := generate_non_overlapping_positions()
	var positions := return_dict["positions"] as Array[Vector3]
	var radii := return_dict["radii"] as Array[float]
	for index in positions.size():
		var asteroid_instance: Asteroid = ASTEROID_SCENE.instantiate()
		instantiated_root.add_child(asteroid_instance)
		asteroid_instance.global_position = positions[index]
		asteroid_instance.set_mass_with_scale(radii[index] * 2.0)
