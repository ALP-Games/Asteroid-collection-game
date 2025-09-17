class_name UpgradeItemRes extends ShopItemResDefaultsAbstract

@export var icon: Texture2D
@export var item_type: ShopManager.ItemType
@export var data: Array[UpgradeEntry2] # IUpgradeVariables
@export var item_scene: PackedScene = preload("res://ui/gameplay_ui/shop_item_ui.tscn")

func get_entry(index: int) -> ShopEntry:
	assert(data.size() > 0)
	var entry: ShopEntry
	if index >= data.size():
		entry = data.back()
	elif index < 0:
		entry = data.front()
	else:
		entry = data[index].shop_entry
	_validate_entry(entry) # can implement my own "validation" method
	return entry


func get_icon(_index: int) -> Texture2D:
	return icon


func get_item_type() -> ShopManager.ItemType:
	return item_type


func get_item_scene() -> PackedScene:
	return item_scene
