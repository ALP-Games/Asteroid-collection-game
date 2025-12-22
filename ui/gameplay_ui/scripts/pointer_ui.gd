class_name PointerUI extends Control

const KEY_POINTER_INSTANCE := &"KeyPointerInstance"
const KEY_POS_DELTA_CACHE := &"KeyPosDeltaCache"
const KEY_POS_DELTA_CALCED := &"KeyPosDeltaCalced"

const POINTER_GIZMO = preload("uid://x3e2x8oxiu8b")

@export var shop_pointer_color: Color = Color("#ffcf5e")
@export var collector_pointer_color: Color = Color.WHITE
@export_group("Pointer display")
@export var display_fade_start: float = 25.0
@export var full_alpha_distance: float = 40.0
@export var distance_fade_out: float = 250.0
@export var max_fade_out_value: float = 0.1
@export var closest_max_fade_out: float = 0.3
@export var scale_down_per_instance: float = 0.75
@export var max_scale_down_value: float = 0.1

# maybe having different scene entries is better
# but I will only have 2 types of pointers so no reason to make it
# very scalable
# but 2 scenes probably better

var _target: Node3D
#var _shop_pointers: Dictionary = {}
#var _collector_pointers: Dictionary = {}
var _pointers: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_target = (get_tree().get_first_node_in_group("camera") as
		FancyCameraArmature).camera_3d
	for shop_node in get_tree().get_nodes_in_group("shop"):
		_pointers[shop_node] = {
			KEY_POS_DELTA_CACHE: Vector3.ZERO,
			KEY_POS_DELTA_CALCED: false,
			KEY_POINTER_INSTANCE: _instantiate_shop_pointer()
		}
	for collector_node in get_tree().get_nodes_in_group("collector"):
		_pointers[collector_node] = {
			KEY_POS_DELTA_CACHE: Vector3.ZERO,
			KEY_POS_DELTA_CALCED: false,
			KEY_POINTER_INSTANCE: _instantiate_collector_pointer()
		}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# here is the main braw of the algorithm
	# iterate over nodes
	# find closest one to the camera
	# have it displayed with most opaqueness
	# have other nodes have reduced opaquness
	#_camera.get_global_transform_interpolated().origin
	_update_pointers(get_tree().get_nodes_in_group("shop"), _instantiate_shop_pointer)
	_update_pointers(get_tree().get_nodes_in_group("collector"), _instantiate_collector_pointer)
	pass


func _instantiate_shop_pointer() -> PointerGizmo:
	var pointer_instance := POINTER_GIZMO.instantiate() as PointerGizmo
	add_child(pointer_instance)
	pointer_instance.modulate = shop_pointer_color
	return pointer_instance


func _instantiate_collector_pointer() -> PointerGizmo:
	var pointer_instance := POINTER_GIZMO.instantiate() as PointerGizmo
	add_child(pointer_instance)
	pointer_instance.modulate = collector_pointer_color
	return pointer_instance


func _update_pointers(nodes_to_point_to: Array[Node], new_pointer_func: Callable) -> void:
	# Need to find the closest node
	# or an array sorted based on distance
	# probably can store all the info right away
	nodes_to_point_to.sort_custom(func(node_a: Node3D, node_b: Node3D) -> bool:
		var entry_a := _get_pointer_data_from_dict(node_a, new_pointer_func)
		var entry_b := _get_pointer_data_from_dict(node_b, new_pointer_func)
		var distance_a := _get_distance(node_a, entry_a)
		var distance_b := _get_distance(node_b, entry_b)
		return distance_a < distance_b)
	for index in nodes_to_point_to.size():
		var node_to_point_to: Node3D = nodes_to_point_to[index]
		var entry := _get_pointer_data_from_dict(node_to_point_to, new_pointer_func)
		var distance := _get_distance(node_to_point_to, entry)
		var position_delta := entry[KEY_POS_DELTA_CACHE] as Vector3
		# maybe need to get it as PointerGizmo and modify it's pivot or something?
		var pointer := entry[KEY_POINTER_INSTANCE] as PointerGizmo
		entry[KEY_POS_DELTA_CALCED] = false
		
		# we need angle, and a bunch of other things
		# what did sorting nodes accomplish? How do we shoe the closest one brightest?
		# probably should still fade or something
		# how does switching from closest to second closest would look like?
		# is this too complicated?
		
		if distance >= display_fade_start:
			if distance < full_alpha_distance:
				pointer.modulate.a = lerp(0.0, 1.0, 
					(position_delta.length() - display_fade_start) /
					(full_alpha_distance - display_fade_start))
			else:
				var fade_out_value := closest_max_fade_out if index == 0 else max_fade_out_value
				pointer.modulate.a = max(lerp(1.0, fade_out_value, 
					(position_delta.length() - full_alpha_distance) /
					(distance_fade_out - full_alpha_distance)), fade_out_value)
			#pointer.modify_scale(0.5)
			pointer.modify_scale(max(pow(scale_down_per_instance, index), max_scale_down_value))
			pointer.visible = true
			var angle := Vector3.FORWARD.signed_angle_to(position_delta, Vector3.UP)
			pointer.add_angle(angle)
		else:
			pointer.visible = false


func _get_distance(node: Node3D, entry: Dictionary) -> float:
	var distance_to := 0.0
	var pos_calced := entry.get(KEY_POS_DELTA_CALCED, false) as bool
	if not pos_calced:
		entry[KEY_POS_DELTA_CALCED] = true
		var position_delta := node.get_global_transform_interpolated().origin -\
			_target.get_global_transform_interpolated().origin
		position_delta.y = 0.0 ## <------------------- This is wher we make it 0.0!
		entry[KEY_POS_DELTA_CACHE] = position_delta
		distance_to = position_delta.length()
	else:
		distance_to = (entry[KEY_POS_DELTA_CACHE] as Vector3).length()
	return distance_to


func _get_pointer_data_from_dict(node: Node3D, new_pointer_func: Callable) -> Dictionary:
	var node_entry := _pointers.get(node, {}) as Dictionary
	if node_entry.is_empty():
		var pointer_gizmo: PointerGizmo = new_pointer_func.call()
		node_entry = {
			KEY_POS_DELTA_CACHE: Vector3.ZERO,
			KEY_POS_DELTA_CALCED: false,
			KEY_POINTER_INSTANCE: pointer_gizmo
		}
		node.tree_exiting.connect(func():pointer_gizmo.queue_free(), CONNECT_ONE_SHOT)
		_pointers[node] = node_entry
	return node_entry
