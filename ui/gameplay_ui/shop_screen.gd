class_name ShopScreen extends Control

@onready var shop_items: VBoxContainer = $HBoxContainer/Content/VBoxContainer/ShopContentContainer/ScrollContainer/ShopItems


func _ready() -> void:
	for child in shop_items.get_children():
		child.queue_free()
	
	var upgrade_data := GameManager.upgrade_data
	for index in UpgradeData.UpgradeType.UPGRADE_COUNT:
		var shop_data := upgrade_data.get_shop_data(index)
		if not shop_data:
			continue
		var new_shop_item: ShopItem = upgrade_data.get_scene(index).instantiate()
		shop_items.add_child(new_shop_item)
		new_shop_item.item_name.text = shop_data.upgrade_name
		new_shop_item.item_price.text = str(shop_data.upgrade_price)
		new_shop_item.upgrade_price = shop_data.upgrade_price
		if GameManager.credist_amount < shop_data.upgrade_price:
			new_shop_item.buy_button.disabled = true
		new_shop_item.buy_button.text = shop_data.buy_text
		new_shop_item.upgrade_id = (index as UpgradeData.UpgradeType)
		new_shop_item.icon.texture = upgrade_data.get_icon(index)
	visible = false
