@tool
class_name RadiusNode3D extends Node3D

@export var radius: float = 2.0:
	set(value):
		radius = value
		if Engine.is_editor_hint():
			update_gizmos()
