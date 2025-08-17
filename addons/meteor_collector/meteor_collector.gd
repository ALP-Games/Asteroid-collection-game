@tool
extends EditorPlugin

var radius_gizmo: RadiusGizmo3D

func _enter_tree() -> void:
	radius_gizmo = RadiusGizmo3D.new()
	add_node_3d_gizmo_plugin(radius_gizmo)


func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(radius_gizmo)
