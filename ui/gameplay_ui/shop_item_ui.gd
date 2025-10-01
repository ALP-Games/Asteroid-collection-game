class_name ShopItemUI extends PanelContainer

@onready var icon: TextureRect = $VBoxContainer/NameAndIcon/Frame/Icon
@onready var item_name: Label = $VBoxContainer/NameAndIcon/FlavorEstate/PanelContainer/ItemName
@onready var item_price: Label = $VBoxContainer/HBoxContainer/PanelContainer/ItemPrice
@onready var buy_button: Button = $VBoxContainer/HBoxContainer/BuyButton
@onready var click_sound_player: AudioStreamPlayer = $ClickSoundPlayer

var upgrade_price: int = 0
var item_id: ShopManager.ItemType

# what is an upgrade?
# upgrades can have levels?
# how are these levels defined?

# upgrade is some kind of data that can be looked up and we can change some kind of player related number
func _ready() -> void:
	GameManager.credits_amount_changed.connect(_on_credits_amount_changed)
	buy_button.button_down.connect(func():click_sound_player.play())
	buy_button.pressed.connect(_try_buy_item)


func initialize() -> void:
	_check_has_enough()


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
		
		var shop_data := shop.get_shop_data(item_id)
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
		item_name.text = shop_data.item_name
		_check_has_enough()


func _check_has_enough() -> void:
	if GameManager.credist_amount >= upgrade_price:
		buy_button.focus_mode = Control.FOCUS_ALL
		buy_button.disabled = false
	else:
		buy_button.release_focus()
		buy_button.focus_mode = Control.FOCUS_NONE
		buy_button.disabled = true
