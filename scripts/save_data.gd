class_name SaveData extends RefCounted

var fresh_load: bool = true

@export var credist_amount: int = 0

@export var player_position: Vector3

@export var items_bought: PackedInt32Array # these need to come from the save
@export var upgrade_levels: PackedInt32Array

enum POS_ELEM {
	POS_OFFSET,
	ROT_OFFSET,
	TOTAL
}
@export var position_states: PackedVector3Array

func register_pos_id(id: int) -> void:
	var last_elem := id * POS_ELEM.TOTAL + POS_ELEM.TOTAL
	if last_elem > position_states.size():
		position_states.resize(last_elem)

func get_pos_state(id: int) -> Vector3:
	return position_states[id * POS_ELEM.TOTAL + POS_ELEM.POS_OFFSET]

func set_pos_state(id: int, pos: Vector3) -> void:
	position_states[id * POS_ELEM.TOTAL + POS_ELEM.POS_OFFSET] = pos

func get_rot_state(id: int) -> Vector3:
	return position_states[id * POS_ELEM.TOTAL + POS_ELEM.ROT_OFFSET]

func set_rot_state(id: int, rot: Vector3) -> void:
	position_states[id * POS_ELEM.TOTAL + POS_ELEM.ROT_OFFSET] = rot


#const PHYSICS_STATE_ELEMENTS = 2
#const LINEAR_VELOCITY_OFFSET = 0
#const ANGULAR_VELOCITY_OFFSET = 1
#@export var physics_states: PackedVector3Array
