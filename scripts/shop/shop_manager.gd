class_name ShopManager extends RefCounted

enum ItemType {
	UNDEFINED = -1,
	HOOK_COUNT,
	ENGINE_POWER,
	WEIGHT,
	DEBT,
	GRINDER,
	ITEM_COUNT
}

var items_dir := DirAccess.open("res://resources/shop/")
var shop_items: Array[IShopItemRes] = []

func _init() -> void:
	shop_items.resize(ItemType.ITEM_COUNT)
	items_dir.list_dir_begin()
	var file_name := items_dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			#print(file_name)
			var resource := load(file_name)
			if resource is IShopItemRes:
				shop_items.append(resource)
		file_name = items_dir.get_next()
	# read from directory
