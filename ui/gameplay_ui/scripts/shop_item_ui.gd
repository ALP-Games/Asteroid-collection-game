class_name ShopItemUI extends Control

var icon: TextureRect
var item_name: Label
var item_price: Label
var buy_button: Button
@onready var click_sound_player: AudioStreamPlayer = $ClickSoundPlayer

var upgrade_price: int = 0
var item_id: ShopManager.ItemType


func _refresh_item() -> void:
	var shop := GameManager.shop
	var shop_data := shop.get_shop_data(item_id)
	item_name.text = shop_data.item_name
	if shop_data == null:
		queue_free()
		return
	if shop_data.price <= 0:
		buy_button.visible = false
		item_price.visible = false
	else:
		buy_button.text = shop_data.buy_text
		upgrade_price = shop_data.price
		item_price.text = str(upgrade_price)
	_check_has_enough()


# upgrade is some kind of data that can be looked up and we can change some kind of player related number
func _ready() -> void:
	_set_layout_items()
	GameManager.credits_amount_changed.connect(_on_credits_amount_changed)
	buy_button.button_down.connect(func():click_sound_player.play())
	buy_button.pressed.connect(_try_buy_item)


func _set_layout_items() -> void:
	icon = $Panel/ContentEstate/Icon
	item_name = $FlavorEstate/PanelContainer/ItemName
	item_price = $Panel/ContentEstate/HBoxContainer/PanelContainer/ItemPrice
	buy_button = $Panel/ContentEstate/HBoxContainer/BuyButton


func initialize() -> void:
	_refresh_item()


func _exit_tree() -> void:
	GameManager.credits_amount_changed.disconnect(_on_credits_amount_changed)


func _on_credits_amount_changed(_new_amount: int) -> void:
	_check_has_enough()


# most of this code should be in shop item or shop itself
func _try_buy_item() -> void:
	var shop := GameManager.shop
	if shop.buy_item(item_id):
		if not is_inside_tree():
			return
		
		_refresh_item()


func _check_has_enough() -> void:
	if GameManager.credist_amount >= upgrade_price:
		buy_button.focus_mode = Control.FOCUS_ALL
		buy_button.disabled = false
	else:
		buy_button.release_focus()
		buy_button.focus_mode = Control.FOCUS_NONE
		buy_button.disabled = true
