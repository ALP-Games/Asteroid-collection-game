class_name PositionSaveState extends Component

@export var _id: int = -1
var _parent: Node3D


func get_id() -> int:
	return _id


static func core() -> ComponentCore:
	return ComponentCore.new(PositionSaveState)


func _ready() -> void:
	_parent = get_parent()
	var save_data := GameManager.save_data
	var save_current_state := save_data.fresh_load
	if _id < 0:
		_id = save_data.register_new_pos_id()
		save_current_state = true
	else:
		save_data.register_existing_pos_id(_id)
		
	if save_current_state:
		save_data.set_pos_state(_id, _parent.global_position)
		save_data.set_rot_state(_id, _parent.global_rotation)
	else:
		_parent.global_position = save_data.get_pos_state(_id)
		_parent.global_rotation = save_data.get_rot_state(_id)
	
	
	if _parent is RigidBody3D:
		#set_physics_process(false)
		set_physics_process(not _parent.sleeping)
		_parent.sleeping_state_changed.connect(func()->void:
			set_physics_process(not _parent.sleeping))


# this could be done on a timer or something
# or better with a queue
# could also be done with a signal when we want to save all
# that is when we want to use the queue
func _physics_process(_delta: float) -> void:
	var save_data := GameManager.save_data
	save_data.set_pos_state(_id, _parent.global_position)
	save_data.set_rot_state(_id, _parent.global_rotation)
