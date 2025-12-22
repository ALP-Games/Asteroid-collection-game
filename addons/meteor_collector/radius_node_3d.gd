@tool
class_name RadiusNode3D extends Node3D

@export var radius: float = 2.0:
	set(value):
		radius = value
		if Engine.is_editor_hint():
			update_gizmos()


func _ready() -> void:
	add_to_group("exclusion_zones")
