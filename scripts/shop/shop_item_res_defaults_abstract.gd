@abstract class_name ShopItemResDefaultsAbstract extends IShopItemRes

@export var item_name: StringName
@export var buy_text: StringName = &"Buy"

func _validate_entry(entry: ShopEntry) -> void:
	if entry.buy_text.is_empty():
		entry.buy_text = buy_text
	if entry.item_name.is_empty():
		entry.item_name = item_name
