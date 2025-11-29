#TODO: mark as abstract
class_name IShopItemRes extends Resource


func get_entry(_index: int) -> ShopEntry:
	assert(false, "get_entry function must be overriden by implementation!")
	return null


func get_icon(_index: int) -> Texture2D:
	assert(false, "get_icon function must be overriden by implementation!")
	return null


func get_item_type() -> ShopManager.ItemType:
	assert(false, "get_item_type function must be overriden by implementation!")
	return ShopManager.ItemType.UNDEFINED


func get_item_scene() -> PackedScene:
	assert(false, "get_item_scene function must be overriden by implementation!")
	return null
