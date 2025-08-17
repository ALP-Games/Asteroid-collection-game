class_name UpgradeData extends RefCounted

const HOOK_ICON = preload("res://Assets/Icons/HookIcon.png")
const THRUSTER_ICON = preload("res://Assets/Icons/ThrusterIcon.png")
const MONEY_ICON = preload("res://Assets/Icons/MoneyIcon.png")

signal upgrade_incremented(upgrade_id: UpgradeType, level: int)

enum UpgradeType {
	UNDEFINED = -1,
	HOOK_COUNT,
	ENGINE_POWER,
	DEBT,
	UPGRADE_COUNT
}

class UpgradeShopData extends RefCounted:
	var upgrade_name: StringName
	var buy_text: StringName = &"Buy"
	var upgrade_price: int
	func _init(_upgrade_name: StringName, _upgrade_price: int) -> void:
		upgrade_name = _upgrade_name
		upgrade_price = _upgrade_price
	
	func set_buy_text(_buy_text: StringName) -> UpgradeShopData:
		buy_text = _buy_text
		return self

var upgrade_icons: Array[Texture]

var _upgrade_levels: Array[int]

func _init() -> void:
	for index in UpgradeType.UPGRADE_COUNT:
		_upgrade_levels.append(0)
	upgrade_icons.resize(UpgradeType.UPGRADE_COUNT)
	upgrade_icons[UpgradeType.HOOK_COUNT] = HOOK_ICON
	upgrade_icons[UpgradeType.ENGINE_POWER] = THRUSTER_ICON
	upgrade_icons[UpgradeType.DEBT] = MONEY_ICON


func increment_upgrade(type: UpgradeType) -> void:
	_upgrade_levels[type] += 1
	upgrade_incremented.emit(type, _upgrade_levels[type])

# TODO: can move this into arrays, or even better to have it in resource
# if 0, upgrade does not exist and should not be displayed
func get_shop_data(type: UpgradeType) -> UpgradeShopData:
	if type == UpgradeType.UNDEFINED:
		return
	var current_level := _upgrade_levels[type]
	match type:
		UpgradeType.HOOK_COUNT:
			match current_level:
				0:
					return UpgradeShopData.new(&"More hooks 0/5", 100)
				1:
					return UpgradeShopData.new(&"More hooks 1/5", 1000)
				2:
					return UpgradeShopData.new(&"More hooks 2/5", 5000)
				3:
					return UpgradeShopData.new(&"More hooks 3/5", 10000)
				4:
					return UpgradeShopData.new(&"More hooks 4/5", 20000)
				5:
					return UpgradeShopData.new(&"Hooks 5/5", -1)
		UpgradeType.ENGINE_POWER:
			match current_level:
				0:
					return UpgradeShopData.new(&"Engine power 0/3", 200)
				1:
					return UpgradeShopData.new(&"More Engine power 1/3", 400)
				2:
					return UpgradeShopData.new(&"Most Engine power 2/3", 1000)
				3:
					return UpgradeShopData.new(&"Engine power 3/3", -1)
		UpgradeType.DEBT:
			match current_level:
				0:
					return UpgradeShopData.new(&"Corporate debt pay 0/4", 100).set_buy_text(&"Pay")
				1:
					return UpgradeShopData.new(&"Corporate debt pay 1/4", 500).set_buy_text(&"Pay")
				2:
					return UpgradeShopData.new(&"Corporate debt pay 2/4", 1000).set_buy_text(&"Pay")
				3:
					return UpgradeShopData.new(&"Corporate debt pay 3/4", 3000).set_buy_text(&"Pay")
				4:
					return UpgradeShopData.new(&"And one last one payment ;P 4/5", 6000).set_buy_text(&"Pay")
				5:
					return UpgradeShopData.new(&"DEBT PAID!", -1).set_buy_text(&"Pay")
	return null
