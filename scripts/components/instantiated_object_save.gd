class_name InstantiatedObjectSave extends Component

@export var save_position_component: bool = false

var _id: int
var meta_data: Dictionary

var _parent: Node

#var scene
#var meta_data: Dictionary = {}
#var position_id # do we need?

## When loading
# there should be a loader
# when instantiating object
# on ready we get it's loaded component
# and pass it's ID?
# load from ID, but we also need to block this thing from registering new id
# but how do we know?


static func core() -> ComponentCore:
	return ComponentCore.new(InstantiatedObjectSave)


func _ready() -> void:
	_parent = get_parent()
	_parent.ready.connect(_load_object)
	_parent.tree_exiting.connect(_removing_instantiated)
	#print("Scene path - ", scene_path)


func _load_object() -> void:
	# but we need a loader here no?
	if _parent.has_meta(SaveData.INSTANCE_ID_META):
		# TODO: use loader
		var save_data := GameManager.save_data
		_id = _parent.get_meta(SaveData.INSTANCE_ID_META)
		meta_data = save_data.get_instantiated_meta(_id)
		if save_position_component:
			var new_pos_state = PositionSaveState.new()
			new_pos_state._id = save_data.get_pos_id(_id)
			_parent.add_child(new_pos_state)
		InstanceLoader.core().invoke_on_component(_parent,
		func(loader: InstanceLoader)->void:
			loader.load_instance(meta_data)
			)
	else:
		# also need to remove older instantiated objects
		var save_data := GameManager.save_data
		_id = save_data.register_new_instantiated()
		save_data.set_instantiated_scene(_id, _parent.scene_file_path)
		meta_data = save_data.get_instantiated_meta(_id)
		if save_position_component:
			var new_pos_state = PositionSaveState.new()
			new_pos_state.ready.connect(func():
				save_data.set_pos_id(_id, new_pos_state.get_id())
				, CONNECT_ONE_SHOT)
			_parent.add_child(new_pos_state)
		InstanceLoader.core().invoke_on_component(_parent,
		func(loader: InstanceLoader)->void:
			loader.init_instance(meta_data)
			)


func _removing_instantiated() -> void:
	if not GameManager.is_global_deinit():
		GameManager.save_data.free_instantiated(_id)
