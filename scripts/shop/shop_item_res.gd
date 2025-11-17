class_name ShopItemRes extends ShopItemResDefaultsAbstract

@export var icon: Texture2D
@export var item_type: ShopManager.ItemType
@export var data: ShopEntry
@export var item_scene: PackedScene = preload("res://ui/gameplay_ui/scenes/shop_item_ui.tscn")

# should it be indexed?
# I think it's better for them to track their internal state on their own, no?
# but resources should not be "managing" state they should only provide data that is immutable
# but get entry can be part of an interface!

func get_entry(_index: int) -> ShopEntry:
	#assert(data.size() > 0)
	#var entry: ShopEntry
	#if index >= data.size():
		#entry = data.back()
	#elif index < 0:
		#entry = data.front()
	#else:
		#entry = data[index]
	_validate_entry(data)
	return data


func get_icon(_index: int) -> Texture2D:
	return icon


func get_item_type() -> ShopManager.ItemType:
	return item_type


func get_item_scene() -> PackedScene:
	return item_scene
