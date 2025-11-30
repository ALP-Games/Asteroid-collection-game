class_name ShopManager extends RefCounted

enum ItemType {
	UNDEFINED = -1,
	HOOK_COUNT,
	ENGINE_POWER,
	WEIGHT,
	GRINDER,
	DEBT,
	ITEM_COUNT
}

signal item_bought(item_type: ItemType, count: int)

const ITEMS_DIR := "res://resources/shop/"
const SHOP_ITEMS: Array[IShopItemRes] = [
	preload("uid://bcptprw7k0gud"),
	preload("uid://drijoevjjam0y"),
	preload("uid://b2k7xjou34t21"),
	preload("uid://dv3b6gvx6rugq"),
	preload("uid://cc0yj5svu6tf2")
]
var shop_items: Array[IShopItemRes] = []

# we will have data here for now
var _items_bought: PackedInt32Array
var _upgrade_levels: PackedInt32Array

func _init() -> void:
	shop_items.resize(ItemType.ITEM_COUNT)
	_items_bought.resize(ItemType.ITEM_COUNT)
	_upgrade_levels.resize(ItemType.ITEM_COUNT)
	
	for item in SHOP_ITEMS:
		assert(shop_items[item.get_item_type()] == null, "Item with the same ID already added!")
		shop_items[item.get_item_type()] = item
	shop_items.make_read_only()
	call_deferred("_emit_items_bought")
	# read from directory

func _emit_items_bought() -> void:
	for index in ItemType.ITEM_COUNT:
		item_bought.emit(index, _upgrade_levels[index])


func get_upgrade_cur_max(type: ItemType) -> Array[int]:
	if type == ItemType.UNDEFINED:
		return []
	return [_upgrade_levels[type], _items_bought[type]]


## Only for UpgradeItemRes items
func change_upgrade_level(type: ItemType, change: int) -> void:
	assert(type != ItemType.UNDEFINED, "UNDEFINED ItemType!")
	assert(shop_items[type] is UpgradeItemRes, "change_upgrade_level can only be called for items of type UpgradeItemRes")
	var upgrade_item : UpgradeItemRes = shop_items[type]
	var upgrade_change := _upgrade_levels[type] + change
	#!!! keep in mind that all upgrades right now have "fully upgraded" level !!!
	if upgrade_change >= upgrade_item.data.size():
		return
	elif upgrade_change < 0:
		return
	_upgrade_levels[type] = upgrade_change
	item_bought.emit(type, _upgrade_levels[type])


func buy_item(type: ItemType) -> bool:
	if type == ItemType.UNDEFINED:
		return false
	var entry := shop_items[type].get_entry(_items_bought[type])
	if entry.price > GameManager.credist_amount:
		return false
	GameManager.credist_amount -= entry.price
	_items_bought[type] += 1
	# A litle wonky that this thing gets called fro non upgrades too
	if shop_items[type] is UpgradeItemRes:
		change_upgrade_level(type, 1)
	else:
		item_bought.emit(type, 1)
	return true


func get_shop_data(type: ItemType) -> ShopEntry:
	if type == ItemType.UNDEFINED:
		return null
	var bought_amount := _items_bought[type]
	return shop_items[type].get_entry(bought_amount)


func get_icon(type: ItemType) -> Texture2D:
	if type == ItemType.UNDEFINED:
		return null
	var bought_amount := _items_bought[type]
	return shop_items[type].get_icon(bought_amount)


func get_scene(type: ItemType) -> PackedScene:
	if type == ItemType.UNDEFINED:
		return null
	return shop_items[type].get_item_scene()


func get_upgrade_variables(type: ItemType) -> IUpgradeVariables:
	if type == ItemType.UNDEFINED:
		return null
	if shop_items[type] is not UpgradeItemRes:
		return null
	var upgrade_item : UpgradeItemRes = shop_items[type]
	var current_upgrade := _upgrade_levels[type]
	return upgrade_item.get_variables(current_upgrade)
