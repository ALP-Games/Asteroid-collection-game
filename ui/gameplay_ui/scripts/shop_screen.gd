class_name ShopScreen extends Control

signal shop_visibilit_changed(visible: bool)

const PROMPT_END_GAME_UI = preload("uid://xjrrlw1r2i3f")

@onready var shop_items: VBoxContainer = $HBoxContainer/Content/VBoxContainer/ShopContentContainer/ScrollContainer/ShopItems


func _ready() -> void:
	for child in shop_items.get_children():
		child.queue_free()
	
	var shop := GameManager.shop
	
	# need to instantiate HBoxContainers per 3 items
	var hbox_ref: HBoxContainer = null
	for index in ShopManager.ItemType.ITEM_COUNT:
		var shop_data := shop.get_shop_data(index)
		if not shop_data:
			continue
		if not hbox_ref or hbox_ref.get_child_count() >= 3:
			hbox_ref = HBoxContainer.new()
			shop_items.add_child(hbox_ref)
		var new_shop_item: ShopItemUI = shop.get_scene(index).instantiate()
		hbox_ref.add_child(new_shop_item)
		new_shop_item.item_name.text = shop_data.item_name
		new_shop_item.item_price.text = str(shop_data.price)
		new_shop_item.upgrade_price = shop_data.price
		#if GameManager.credist_amount < shop_data.upgrade_price:
			#new_shop_item.buy_button.disabled = true
		new_shop_item.buy_button.text = shop_data.buy_text
		new_shop_item.item_id = (index as ShopManager.ItemType)
		new_shop_item.icon.texture = shop.get_icon(index)
		new_shop_item.initialize()
	if hbox_ref and hbox_ref.get_child_count() < 3:
		var control := Control.new()
		hbox_ref.add_child(control)
		control.size_flags_horizontal |= Control.SIZE_EXPAND
	visible = false


func add_end_game_prompt() -> void:
	var last_hbox :HBoxContainer = shop_items.get_child(shop_items.get_child_count() - 1)
	if last_hbox.get_child_count() > 2:
		var instantiate_new_hbox := true
		for child in last_hbox.get_children():
			if child is not ShopItemUI:
				child.queue_free()
				instantiate_new_hbox = false
				break;
		if instantiate_new_hbox:
			last_hbox = HBoxContainer.new()
			shop_items.add_child(last_hbox)
	last_hbox.add_child(PROMPT_END_GAME_UI.instantiate())


func toggle_shop() -> void:
	var new_state := !visible
	visible = new_state
	shop_visibilit_changed.emit(new_state)
