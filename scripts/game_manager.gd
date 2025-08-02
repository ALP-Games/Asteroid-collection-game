extends Node

const UPPER_ASTEROID_COUNT := 100
var current_asteroid_count := 0

signal credits_amount_changed(new_amount: int)

var upgrade_data: UpgradeData = null

var credist_amount: int = 0:
	set(value):
		credist_amount = value
		credits_amount_changed.emit(credist_amount)


func _init() -> void:
	initialize()


func initialize() -> void:
	credist_amount = 0
	upgrade_data = UpgradeData.new()
	current_asteroid_count = 0
