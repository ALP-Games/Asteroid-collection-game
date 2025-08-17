class_name AsteroidSpawner extends Node3D

const ASTEROID_SCENE = preload("res://actors/asteroid.tscn")

@export var spawn_radius: float = 250.0
@export var min_distance_between_asteroids: float = 10.0
@export var asteroid_scale_max: float = 5
@export var asteroid_scale_min: float = 0.5
@export var spawn_interval_max: float = 5.0
@export var spawn_interval_min: float = 0.5

@export var exclusion_zones: Array[RadiusNode3D]

var asteroid_count: int = 200

func generate_non_overlapping_positions() -> Array[Vector3]:
	# could do packed arrays for speed if needed
	
	var positions: Array[Vector3] = []
	var max_attempts := 1000
	while positions.size() < asteroid_count and max_attempts > 0:
		var pos = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() * randf_range(0, spawn_radius)
	
		var valid := true
		for existing in positions:
			if pos.distance_to(existing) < min_distance_between_asteroids:
				valid = false
				break
		
		if valid:
			positions.append(pos)
		
		max_attempts -= 1
		
	#if positions.size() < asteroid_count:
	return positions


func _ready() -> void:
	var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
	var positions := generate_non_overlapping_positions()
	for asteroid_position in positions:
		var asteroid_instance: Asteroid = ASTEROID_SCENE.instantiate()
		instantiated_root.add_child(asteroid_instance)
		asteroid_instance.global_position = asteroid_position
		asteroid_instance.set_mass_with_scale(randf_range(asteroid_scale_min, asteroid_scale_max))
