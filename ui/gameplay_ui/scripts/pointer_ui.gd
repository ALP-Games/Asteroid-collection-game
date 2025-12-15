class_name PointerUI extends Control

const KEY_POINTER_INSTANCE := &"KeyPointerInstance"
const KEY_DISTANCE_CACHE := &"KeyDistanceCache"

const POINTER_GIZMO = preload("uid://x3e2x8oxiu8b")

@export var shop_pointer_color: Color = Color("#ffcf5e")
@export var collector_pointer_color: Color = Color.WHITE
# maybe having different scene entries is better
# but I will only have 2 types of pointers so no reason to make it
# very scalable
# but 2 scenes probably better

var _camera: Camera3D
var _shop_pointers: Dictionary = {}
var _collector_pointers: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_camera = (get_tree().get_first_node_in_group("camera") as
		FancyCameraArmature).camera_3d
	for shop_node in get_tree().get_nodes_in_group("shop"):
		var pointer_instance := POINTER_GIZMO.instantiate() as PointerGizmo
		add_child(pointer_instance)
		pointer_instance.modulate = shop_pointer_color
		_shop_pointers[shop_node] = {
			KEY_DISTANCE_CACHE: 0.0,
			KEY_POINTER_INSTANCE: pointer_instance
		}
	for collector_node in get_tree().get_nodes_in_group("collector"):
		var pointer_instance := POINTER_GIZMO.instantiate() as PointerGizmo
		add_child(pointer_instance)
		pointer_instance.modulate = collector_pointer_color
		_collector_pointers[collector_node] = {
			KEY_DISTANCE_CACHE: 0.0,
			KEY_POINTER_INSTANCE: pointer_instance
		}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# here is the main braw of the algorithm
	# iterate over nodes
	# find closest one to the camera
	# have it displayed with most opaqueness
	# have other nodes have reduced opaquness
	#_camera.get_global_transform_interpolated().origin
	_update_pointers(get_tree().get_nodes_in_group("shop"))
	_update_pointers(get_tree().get_nodes_in_group("collector"))
	pass


func _update_pointers(nodes_to_point_to: Array[Node]) -> void:
	# Need to find the closest node
	# or an array sorted based on distance
	# probably can store all the info right away
	nodes_to_point_to.sort_custom(func(node_a: Node3D, node_b: Node3D) -> bool:
		# if we cache distance here, that is fine
		# one thing that is not fine is that we don't know the type
		# so maybe a creation function should be passed?
		# (instantiate specific scene, do operations, return instance) - YES CREATION LAMBDA!
		# and we need to put all the pointers into the same dictionary?
		return false)
	for node_to_point_to: Node3D in nodes_to_point_to:
		var distance_to := node_to_point_to.get_global_transform_interpolated().origin -\
			_camera.get_global_transform_interpolated().origin
		
	pass
