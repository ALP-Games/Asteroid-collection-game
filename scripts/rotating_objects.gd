@tool
class_name RotatingObjects extends Node

@export var rotation_objects: Array[Node3D]

@export var graphics_rotation: Vector3:
	set(value):
		graphics_rotation = value
		if not is_node_ready():
			return
		_update_rotations()


func _ready() -> void:
	_update_rotations()


func _update_rotations() -> void:
	var target_rotation := deg_to_rad_vec(graphics_rotation)
	for object in rotation_objects:
		object.rotation = target_rotation


func deg_to_rad_vec(degrees_vector: Vector3) -> Vector3:
	return Vector3(deg_to_rad(degrees_vector.x), deg_to_rad(degrees_vector.y), deg_to_rad(degrees_vector.z))
