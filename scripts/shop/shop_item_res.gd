class_name ShopItemRes extends Resource

@export var icon: Texture2D
@export var item_type: Shop.ItemType
@export var data: Array[ShopEntry]
@export var item_scene: PackedScene = preload("res://ui/gameplay_ui/shop_item.tscn")

@export_group("Shop Entry Defaults")
@export var item_name: StringName
@export var buy_text: StringName = &"Buy"


func get_entry(index: int) -> ShopEntry:
	assert(data.size() > 0)
	var entry: ShopEntry
	if index >= data.size():
		entry = data.back()
	elif index < 0:
		entry = data.front()
	else:
		entry = data[index]
	_validate_entry(entry)
	return entry


func _validate_entry(entry: ShopEntry) -> void:
	if entry.buy_text.is_empty():
		entry.buy_text = buy_text
	if entry.item_name.is_empty():
		entry.item_name = item_name
