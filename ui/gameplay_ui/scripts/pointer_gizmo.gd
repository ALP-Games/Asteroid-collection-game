class_name PointerGizmo extends Control

@onready var pointer_pivot: Control = $PointerPivot
#@onready var po_i_icon: TextureRect = $PointerPivot/PoIIcon


func _ready() -> void:
	pointer_pivot.pivot_offset = Vector2(pointer_pivot.size.x / 2, pointer_pivot.size.y / 2)
	#po_i_icon.pivot_offset = Vector2(po_i_icon.size.x / 2, po_i_icon.size.y / 2)


func add_angle(angle: float) -> void:
	pointer_pivot.rotation = -angle
	#po_i_icon.rotation = angle
