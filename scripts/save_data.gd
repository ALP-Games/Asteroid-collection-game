class_name SaveData extends RefCounted

var fresh_load: bool = true

@export var credist_amount: int = 0

@export var player_position: Vector3

@export var items_bought: PackedInt32Array # these need to come from the save
@export var upgrade_levels: PackedInt32Array
