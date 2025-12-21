class_name ShopManager extends RefCounted

enum ItemType {
	UNDEFINED = -1,
	DEBT,
	ITEM_COUNT
}

signal item_bought(item_type: ItemType, count: int)

const SHOP_ITEMS: Array[IShopItemRes] = [
	preload("res://resources/shop/debt.tres")
]
#uid://bcptprw7k0gud
var shop_items: Array[IShopItemRes] = []

func _init() -> void:
	shop_items.resize(ItemType.ITEM_COUNT)
	
	for item in SHOP_ITEMS:
		assert(shop_items[item.get_item_type()] == null, "Item with the same ID already added!")
		shop_items[item.get_item_type()] = item
	shop_items.make_read_only()
	call_deferred("_emit_items_bought")


func _emit_items_bought() -> void:
	for index in ItemType.ITEM_COUNT:
		item_bought.emit(index, 0)


func get_upgrade_variables(type: ItemType) -> IUpgradeVariables:
	if type == ItemType.UNDEFINED:
		return null
	if shop_items[type] is not UpgradeItemRes:
		return null
	var upgrade_item : UpgradeItemRes = shop_items[type]
	var current_upgrade := 0
	return upgrade_item.get_variables(current_upgrade)
