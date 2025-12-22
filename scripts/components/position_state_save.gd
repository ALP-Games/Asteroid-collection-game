class_name PositionSaveState extends Component

@export var _id: int
var _parent: Node3D


static func core() -> ComponentCore:
	return ComponentCore.new(PositionSaveState)


func _ready() -> void:
	_parent = get_parent()
	var save_data := GameManager.save_data
	save_data.register_pos_id(_id)
	if save_data.fresh_load:
		#save_data.position_states[_id * SaveData.elemen]
		save_data.set_pos_state(_id, _parent.global_position)
		save_data.set_rot_state(_id, _parent.global_rotation)
	else:
		_parent.global_position = save_data.get_pos_state(_id)
		_parent.global_rotation = save_data.get_rot_state(_id)


func _physics_process(_delta: float) -> void:
	var save_data := GameManager.save_data
	save_data.set_pos_state(_id, _parent.global_position)
	save_data.set_rot_state(_id, _parent.global_rotation)
