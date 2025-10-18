class_name Gizmos extends Control

const RIGHT_CLICK_GIZMO = preload("uid://cgjsot8bv83rv")


func _ready() -> void:
	add_to_group("gizmos_ui")


# we add it
# then the user enables it?
# I think the user shoud not be enabing it
func add_right_cick_gizmo() -> RightClickGizmo:
	var instance := RIGHT_CLICK_GIZMO.instantiate() as RightClickGizmo
	add_child(instance)
	return instance
