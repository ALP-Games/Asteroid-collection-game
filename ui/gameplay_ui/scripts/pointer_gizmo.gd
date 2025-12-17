class_name PointerGizmo extends Control

@onready var pointer_pivot: Control = $PointerPivot
#@onready var po_i_icon: TextureRect = $PointerPivot/PoIIcon
@onready var arrow_icon: TextureRect = $PointerPivot/ArrowIcon
@onready var original_scale := arrow_icon.scale

func _ready() -> void:
	pointer_pivot.pivot_offset = Vector2(pointer_pivot.size.x / 2, pointer_pivot.size.y / 2)
	#po_i_icon.pivot_offset = Vector2(po_i_icon.size.x / 2, po_i_icon.size.y / 2)


func add_angle(angle: float) -> void:
	pointer_pivot.rotation = -angle
	#po_i_icon.rotation = angle


func modify_scale(new_scale: float) -> void:
	arrow_icon.scale.x = original_scale.x * new_scale
