class_name ShopItem extends PanelContainer

@onready var item_name: Label = $VBoxContainer/PanelContainer/ItemName
@onready var item_price: Label = $VBoxContainer/HBoxContainer/PanelContainer/ItemPrice
@onready var buy_button: Button = $VBoxContainer/HBoxContainer/BuyButton

var upgrade_price: int = 0
var upgrade_id: UpgradeData.UpgradeType

# what is an upgrade?
# upgrades can have levels?
# how are these levels defined?

# upgrade is some kind of data that can be looked up and we can change some kind of player related number
func _ready() -> void:
	buy_button.pressed.connect(_try_buy_upgrade)


func _try_buy_upgrade() -> void:
	if GameManager.credist_amount >= upgrade_price:
		GameManager.credist_amount -= upgrade_price
		var upgrade_data := GameManager.upgrade_data
		upgrade_data.increment_upgrade(upgrade_id)
		
		var shop_data := upgrade_data.get_shop_data(upgrade_id)
		upgrade_price = shop_data.upgrade_price
		
		item_name.text = shop_data.upgrade_name
		item_price.text = str(upgrade_price)
	#UpgradeData.sho
