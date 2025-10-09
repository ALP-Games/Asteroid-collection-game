class_name MaterialOverlayer extends Node

@export var meshes: Array[MeshInstance3D]
@export var material_overlay: Material

func overlay_active() -> bool:
	for mesh in meshes:
		if mesh.material_overlay != material_overlay:
			return false
	return meshes.size() > 0

func overlay_material() -> void:
	for mesh in meshes:
		mesh.material_overlay = material_overlay


func reset_overlayed_material() -> void:
	for mesh in meshes:
		mesh.material_overlay = null
