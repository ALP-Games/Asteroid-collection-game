class_name PointerGizmo extends Control

@onready var pointer_pivot: Control = $PointerPivot
@onready var po_i_icon: TextureRect = $PointerPivot/PoIIcon

@export var display_fade_start: float = 25.0
@export var full_alpha_distance: float = 40.0
@export var distance_fade_out: float = 250.0
@export var max_fade_out_value: float = 0.1 

var _player_ship: PlayerShip
var _camera: Camera3D
var _target: RigidBody3D


func _ready() -> void:
	pointer_pivot.visible = false
	pointer_pivot.pivot_offset = Vector2(pointer_pivot.size.x / 2, pointer_pivot.size.y / 2)
	po_i_icon.pivot_offset = Vector2(po_i_icon.size.x / 2, po_i_icon.size.y / 2)
	_player_ship = get_tree().get_first_node_in_group("player")
	_camera = (get_tree().get_first_node_in_group("camera") as FancyCameraArmature).camera_3d
	# This should point to the closest?
	# We should have a pointer to the shop
	_target = get_tree().get_first_node_in_group("shop")
	if not _target:
		set_physics_process(false)


#func _process(delta: float) -> void:
# maybe there should be some kind of manager of pointers?
# because for example to show the closest one with the highest alpha and the furthest ones with less alpha
# but then the current pointer works quite differently
# how to we instantiate more pointers? It has to come from the objects that we point to
# or no, it can just work from get_tree().get_nodes_in_group()
# but how would we add new entries through this?
# it makes sense to add new entries through the manager when new element is added
# and we don't have a new thing in it


# this functionality will be in the pointer manager
func _physics_process(_delta: float) -> void:
	var position_delta := _target.get_global_transform_interpolated().origin - _camera.get_global_transform_interpolated().origin
	position_delta.y = 0.0
	# maybe display distance should fade in
	# yeah, should modulate alpha of the current node
	if position_delta.length() >= display_fade_start:
		if position_delta.length() < full_alpha_distance:
			modulate.a = lerp(0.0, 1.0, 
				(position_delta.length() - display_fade_start) /
				(full_alpha_distance - display_fade_start))
		#else:
			#modulate.a = max(lerp(1.0, max_fade_out_value, 
				#(position_delta.length() - full_alpha_distance) /
				#(distance_fade_out - full_alpha_distance)), max_fade_out_value)
		pointer_pivot.visible = true
		var angle := Vector3.FORWARD.signed_angle_to(position_delta, Vector3.UP)
		pointer_pivot.rotation = -angle
		po_i_icon.rotation = angle
	else:
		pointer_pivot.visible = false
