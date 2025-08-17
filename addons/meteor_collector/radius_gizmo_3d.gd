@tool
class_name RadiusGizmo3D extends EditorNode3DGizmoPlugin


func _get_gizmo_name() -> String:
	return "RadiusGizmo3D"


func _init() -> void:
	var color = Color(1, 0, 0)
	create_material("radius_material", color)

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is RadiusNode3D


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	var node = gizmo.get_node_3d() as RadiusNode3D
	gizmo.clear()
	gizmo.add_lines(_make_circle_xz(node.radius), get_material("radius_material"))
	gizmo.add_lines(_make_circle_yz(node.radius), get_material("radius_material"))


func _make_circle_xz(radius: float) -> PackedVector3Array:
	var points = PackedVector3Array()
	var steps = 32
	for i in steps:
		var angle = TAU * float(i) / float(steps)
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		points.append(Vector3(x, 0, z))
		# connect line to next point
		if i > 0:
			points.append(Vector3(x, 0, z))
	# close loop
	points.append(points[0])
	return points


func _make_circle_yz(radius: float) -> PackedVector3Array:
	var points = PackedVector3Array()
	var steps = 32
	for i in steps:
		var angle = TAU * float(i) / float(steps)
		var y = cos(angle) * radius
		var z = sin(angle) * radius
		points.append(Vector3(0, y, z))
		# connect line to next point
		if i > 0:
			points.append(Vector3(0, y, z))
	# close loop
	points.append(points[0])
	return points
