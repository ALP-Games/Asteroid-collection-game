class_name UpgradeData extends RefCounted

signal upgrade_incremented(upgrade_id: UpgradeType, level: int)

enum UpgradeType {
	UNDEFINED = -1,
	HOOK_COUNT,
	ENGINE_POWER,
	DEBT,
	UPGRADE_COUNT
}

const _UPGRADE_DATA: Array[UpgradeDataRes] = [
	preload("res://resources/upgrades/hook_count_upgrade.tres"),
	preload("res://resources/upgrades/engine_upgrade.tres"),
	preload("res://resources/upgrades/debt.tres")
]

var _upgrade_levels: Array[int]

func _init() -> void:
	for index in UpgradeType.UPGRADE_COUNT:
		_upgrade_levels.append(0)
	
	#upgrade_data.resize(UpgradeType.UPGRADE_COUNT)
	#upgrade_data[UpgradeType.HOOK_COUNT] = HOOK_COUNT_UPGRADE
	#upgrade_data[UpgradeType.ENGINE_POWER] = ENGINE_UPGRADE
	#upgrade_data[UpgradeType.DEBT] = DEBT


func increment_upgrade(type: UpgradeType) -> void:
	_upgrade_levels[type] += 1
	upgrade_incremented.emit(type, _upgrade_levels[type])


func get_shop_data(type: UpgradeType) -> UpgradeEntry:
	if type == UpgradeType.UNDEFINED:
		return
	var current_level := _upgrade_levels[type]
	return _UPGRADE_DATA[type].get_data(current_level)


func get_icon(type: UpgradeType) -> Texture2D:
	if type == UpgradeType.UNDEFINED:
		return
	return _UPGRADE_DATA[type].icon
