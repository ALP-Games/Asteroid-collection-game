## TODO: Add short component description
class_name GizmoIconControl
extends Component

@export var _gizmo_icon: TextureRect

static func core() -> ComponentCore:
	return ComponentCore.new(GizmoIconControl)


func set_color(color: Color) -> void:
	_gizmo_icon.modulate.r = color.r
	_gizmo_icon.modulate.g = color.g
	_gizmo_icon.modulate.b = color.b
