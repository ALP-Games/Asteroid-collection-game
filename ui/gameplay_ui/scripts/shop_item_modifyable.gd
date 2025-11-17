class_name ShopItemModifyable extends ShopItemUI

const COUNT_FORMAT := &"%1d/%1d"

@onready var text_count: Label = $ContentContainer/ContentEstate/PanelAdjustable/TextContainer/TextCount
@onready var button_add: Button = $ContentContainer/ContentEstate/PanelAdjustable/ButtonsBox/ButtonAdd
@onready var button_remove: Button = $ContentContainer/ContentEstate/PanelAdjustable/ButtonsBox/ButtonRemove


#var upgrade_cur_max: Array[int]


func _ready() -> void:
	super()
	var shop := GameManager.shop
	shop.item_bought.connect(_on_item_bought)
	_check_item_numbers()
	
	button_add.pressed.connect(_change_upgrade_level.bind(1))
	button_remove.pressed.connect(_change_upgrade_level.bind(-1))
	
	button_add.button_down.connect(func():click_sound_player.play())
	button_remove.button_down.connect(func():click_sound_player.play())

func _set_layout_items() -> void:
	icon = $ContentContainer/ContentEstate/Icon
	item_name = $NameContainer/ItemName
	item_price = $ContentContainer/ContentEstate/BuyAndPrice/PanelContainer/ItemPrice
	buy_button = $ContentContainer/ContentEstate/BuyAndPrice/BuyButton


func _on_item_bought(_item_type: ShopManager.ItemType, _count: int) -> void:
	_check_item_numbers()


func _check_item_numbers() -> void:
	var upgrade_cur_max := GameManager.shop.get_upgrade_cur_max(item_id)
	button_add.disabled = upgrade_cur_max[0] == upgrade_cur_max[1]
	button_remove.disabled = upgrade_cur_max[0] == 0
	text_count.text = COUNT_FORMAT % upgrade_cur_max


func _change_upgrade_level(change: int) -> void:
	GameManager.shop.change_upgrade_level(item_id, change)
