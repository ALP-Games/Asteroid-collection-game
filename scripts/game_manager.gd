extends Node

const VICTORY_LEVEL = preload("res://levels/victory_level.tscn")

const UPPER_ASTEROID_COUNT := 100
var current_asteroid_count := 0

signal credits_amount_changed(new_amount: int)

var upgrade_data: UpgradeData = null

var credist_amount: int = 0:
	set(value):
		credist_amount = value
		credits_amount_changed.emit(credist_amount)


func _ready() -> void:
	upgrade_data.upgrade_incremented.connect(_check_victory)


func _check_victory(upgrade_id: UpgradeData.UpgradeType, upgrade_level: int) -> void:
	if upgrade_id != UpgradeData.UpgradeType.DEBT:
		return
	if upgrade_level == 5:
		get_tree().change_scene_to_packed(VICTORY_LEVEL)
		

func _init() -> void:
	_initialize()


func _initialize() -> void:
	credist_amount = 15000
	upgrade_data = UpgradeData.new()
	current_asteroid_count = 0


func reload() -> void:
	get_tree().paused = false
	_initialize()
	get_tree().reload_current_scene()
