class_name MassUpgradeVariables extends IUpgradeVariables

@export var mass: float = 1000

class MassUpgradeData extends RefCounted:
	var mass: float


func get_data() -> MassUpgradeData:
	var data := MassUpgradeData.new()
	data.mass = mass
	return data
