class_name ShopScreen extends Control

const SHOP_ITEM = preload("res://ui/shop_item.tscn")

@onready var shop_items: VBoxContainer = $HBoxContainer/Content/VBoxContainer/ShopContentContainer/ScrollContainer/ShopItems


func _ready() -> void:
	for child in shop_items.get_children():
		child.queue_free()
	
	var upgrade_data := GameManager.upgrade_data
	for index in UpgradeData.UpgradeType.UPGRADE_COUNT:
		var shop_data := upgrade_data.get_shop_data(index)
		if not shop_data:
			continue
		var new_shop_item: ShopItem = SHOP_ITEM.instantiate()
		shop_items.add_child(new_shop_item)
		new_shop_item.item_name.text = shop_data.upgrade_name
		new_shop_item.item_price.text = str(shop_data.upgrade_price)
		new_shop_item.upgrade_price = shop_data.upgrade_price
		new_shop_item.upgrade_id = index
	visible = false
