class_name UpgradeData extends RefCounted

const HOOK_ICON = preload("res://Assets/Icons/HookIcon.png")
const THRUSTER_ICON = preload("res://Assets/Icons/ThrusterIcon.png")

signal upgrade_incremented(upgrade_id: UpgradeType, level: int)

enum UpgradeType {
	UNDEFINED = -1,
	HOOK_COUNT,
	ENGINE_POWER,
	UPGRADE_COUNT
}

class UpgradeShopData extends RefCounted:
	var upgrade_name: StringName
	var upgrade_price: int
	func _init(_upgrade_name: StringName, _upgrade_price: int) -> void:
		upgrade_name = _upgrade_name
		upgrade_price = _upgrade_price

var upgrade_icons: Array[Texture]

var _upgrade_levels: Array[int]

func _init() -> void:
	for index in UpgradeType.UPGRADE_COUNT:
		_upgrade_levels.append(0)
	upgrade_icons.resize(UpgradeType.UPGRADE_COUNT)
	upgrade_icons[UpgradeType.HOOK_COUNT] = HOOK_ICON
	upgrade_icons[UpgradeType.ENGINE_POWER] = THRUSTER_ICON


func increment_upgrade(type: UpgradeType) -> void:
	_upgrade_levels[type] += 1
	upgrade_incremented.emit(type, _upgrade_levels[type])

# if 0, upgrade does not exist and should not be displayed
func get_shop_data(type: UpgradeType) -> UpgradeShopData:
	if type == UpgradeType.UNDEFINED:
		return
	var current_level := _upgrade_levels[type]
	match type:
		UpgradeType.HOOK_COUNT:
			match current_level:
				0:
					return UpgradeShopData.new(&"More hooks", 100)
				1:
					return UpgradeShopData.new(&"More hooks", 1000)
				2:
					return UpgradeShopData.new(&"More hooks", 5000)
				3:
					return UpgradeShopData.new(&"More hooks", 10000)
				4:
					return UpgradeShopData.new(&"More hooks (last one)", 20000)
		UpgradeType.ENGINE_POWER:
			match current_level:
				0:
					return UpgradeShopData.new(&"Engine power", 200)
				1:
					return UpgradeShopData.new(&"More Engine power", 400)
				2:
					return UpgradeShopData.new(&"Most Engine power", 1000)
	return null
