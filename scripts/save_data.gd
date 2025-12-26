class_name SaveData extends RefCounted

var fresh_load: bool = true

@export var credist_amount: int = 0

@export var player_position: Vector3

@export var items_bought: PackedInt32Array # these need to come from the save
@export var upgrade_levels: PackedInt32Array

@export var save_meta_data: Dictionary

enum POS_ELEM {
	POS_OFFSET,
	ROT_OFFSET,
	TOTAL
}
@export var position_states: PackedVector3Array
@export var _freed_position_ids: PackedInt32Array

func register_existing_pos_id(id: int) -> void:
	var last_elem := id * POS_ELEM.TOTAL + POS_ELEM.TOTAL
	if last_elem > position_states.size():
		position_states.resize(last_elem)


func register_new_pos_id() -> int:
	var fresh_id: int
	if _freed_position_ids.size() > 0:
		fresh_id = _freed_position_ids[_freed_position_ids.size() - 1]
		_freed_position_ids.resize(_freed_position_ids.size() - 1)
	else:
		var new_element_count := position_states.size() + POS_ELEM.TOTAL
		position_states.resize(new_element_count)
		fresh_id = (new_element_count - POS_ELEM.TOTAL) / POS_ELEM.TOTAL
	return fresh_id

func free_pos_id(id: int) -> void:
	_freed_position_ids.append(id)

#func free_instantiated(id: int) -> void:
	#instantiated_objects[id][InstKeys.FREED] = true
	#_freed_instantiated_ids.append(id)


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

# we need to save what scenes to isntantiate
# like if a new object that should be saved gets
# so we need an instantiated object dictionary or something

const INSTANCE_ID_META = "MetaInstanceId"
class InstKeys extends Object:
	const SCENE = &"KeyScene"
	const POS = &"KeyPosition"
	const META = &"KeyMetaData"
	const FREED = &"KeyFreed"


@export var instantiated_objects: Array[Dictionary]
@export var _freed_instantiated_ids: PackedInt32Array


func register_new_instantiated() -> int:
	var fresh_id: int
	if _freed_instantiated_ids.size() > 0:
		fresh_id = _freed_instantiated_ids[_freed_instantiated_ids.size() - 1]
		_freed_instantiated_ids.resize(_freed_instantiated_ids.size() - 1)
	else:
		fresh_id = instantiated_objects.size()
		instantiated_objects.resize(fresh_id + 1)
	instantiated_objects[fresh_id][InstKeys.META] = {}
	instantiated_objects[fresh_id][InstKeys.FREED] = false
	return fresh_id

func free_instantiated(id: int) -> void:
	var entry := instantiated_objects[id]
	entry[InstKeys.FREED] = true
	if entry.has(InstKeys.POS):
		free_pos_id(entry[InstKeys.POS])
	_freed_instantiated_ids.append(id)


func get_instantiated_scene(id: int) -> String:
	return instantiated_objects[id].get(InstKeys.SCENE, "")

func set_instantiated_scene(id: int, scene_path: String) -> void:
	instantiated_objects[id][InstKeys.SCENE] = scene_path


# set should not be needed because Dictionary is a ref
func get_instantiated_meta(id: int) -> Dictionary:
	return instantiated_objects[id][InstKeys.META]


func get_pos_id(id: int) -> int:
	return instantiated_objects[id].get(InstKeys.POS, -1)

func set_pos_id(id: int, pos_id: int) -> void:
	instantiated_objects[id][InstKeys.POS] = pos_id


func instantiate_saved_objects() -> void:
	var instantiated_root := GameManager.get_tree().get_first_node_in_group("instantiated_root")
	for id: int in instantiated_objects.size():
		var obj_data: Dictionary = instantiated_objects[id]
		if obj_data[InstKeys.FREED]:
			continue
		var scene := (load(obj_data[InstKeys.SCENE]) as PackedScene).instantiate()
		scene.set_meta(INSTANCE_ID_META, id)
		instantiated_root.add_child(scene)
