class_name UpgradeData extends RefCounted

signal upgrade_incremented(upgrade_id: UpgradeType, level: int)

# we need upgrades bought and upgrades incremented?
# do we need upgrades bought array then?

enum UpgradeType {
	UNDEFINED = -1,
	HOOK_COUNT,
	ENGINE_POWER,
	WEIGHT,
	DEBT,
	GRINDER,
	UPGRADE_COUNT
}

# need to restructure things to be shop items insead of upgrades at this point
# how to do that?

# this could be just taken from a directory
const _UPGRADE_DATA: Array[UpgradeDataRes] = [
	preload("res://resources/upgrades/hook_count_upgrade.tres"),
	preload("res://resources/upgrades/engine_upgrade.tres"),
	preload("res://resources/upgrades/weight_upgrade.tres"),
	preload("res://resources/upgrades/debt.tres"),
	preload("res://resources/upgrades/grinder.tres")
]

# TODO: change to packed arrays
var _upgrade_levels_bought: Array[int]
var _upgrade_levels: Array[int]

func _init() -> void:
	_upgrade_levels_bought.resize(UpgradeType.UPGRADE_COUNT)
	_upgrade_levels.resize(UpgradeType.UPGRADE_COUNT)
	#for index in UpgradeType.UPGRADE_COUNT:
		#_upgrade_levels_bought.append(0)
		#_upgrade_levels.append(0)
	call_deferred("_emit_upgrades")
	#upgrade_data.resize(UpgradeType.UPGRADE_COUNT)
	#upgrade_data[UpgradeType.HOOK_COUNT] = HOOK_COUNT_UPGRADE
	#upgrade_data[UpgradeType.ENGINE_POWER] = ENGINE_UPGRADE
	#upgrade_data[UpgradeType.DEBT] = DEBT


# Maybe it's better to have a function that would query an upgrade level
# For specific upgrade type
func _emit_upgrades() -> void:
	for index in UpgradeType.UPGRADE_COUNT:
		upgrade_incremented.emit(index, _upgrade_levels[index])

func get_upgrade_cur_max(type: UpgradeType) -> Array[int]:
	if type == UpgradeType.UNDEFINED:
		return []
	return [_upgrade_levels[type], _upgrade_levels_bought[type]]


func change_upgrade_level(type: UpgradeType, change: int) -> void:
	if type == UpgradeType.UNDEFINED:
		return
	var upgrade_data := _UPGRADE_DATA[type]
	var upgrade_change := _upgrade_levels[type] + change
	#!!! keep in mind that all upgrades right now have "fully upgraded" level !!!
	if upgrade_change >= upgrade_data.data.size():
		return
	elif upgrade_change < 0:
		return
	_upgrade_levels[type] = upgrade_change
	upgrade_incremented.emit(type, _upgrade_levels[type])


# maybe this should be a "buy" upgrade and actually chanrge the player?
func increment_upgrade(type: UpgradeType) -> void:
	if type == UpgradeType.UNDEFINED:
		return
	_upgrade_levels_bought[type] += 1
	change_upgrade_level(type, 1)


func get_shop_data(type: UpgradeType) -> UpgradeEntry:
	if type == UpgradeType.UNDEFINED:
		return
	var current_level := _upgrade_levels_bought[type]
	return _UPGRADE_DATA[type].get_data(current_level)


func get_icon(type: UpgradeType) -> Texture2D:
	if type == UpgradeType.UNDEFINED:
		return
	return _UPGRADE_DATA[type].icon


func get_scene(type: UpgradeType) -> PackedScene:
	if type == UpgradeType.UNDEFINED:
		return
	return _UPGRADE_DATA[type].upgrade_scene


func get_upgrade_variables(type: UpgradeType) -> IUpgradeVariables:
	if type == UpgradeType.UNDEFINED:
		return
	var current_level := _upgrade_levels_bought[type]
	return _UPGRADE_DATA[type].variables[current_level]
