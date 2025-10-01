class_name ThrusterUpgradeVariables extends IUpgradeVariables

@export var acceleration: float = 20
@export var stop_linear_amount: float = 20
@export var reverse_acceleration: float = 10


class ThrusterData extends RefCounted:
	var thrust_force: float
	var stop_linear_amount: float
	var reverse_force: float


func get_data(starting_mass: float) -> ThrusterData:
	var data := ThrusterData.new()
	data.thrust_force = starting_mass * acceleration
	data.reverse_force = starting_mass * reverse_acceleration
	data.stop_linear_amount = starting_mass * stop_linear_amount
	return data
