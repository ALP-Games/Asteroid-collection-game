extends Node

var first_start: bool = true # I guess this has to come from save file or whatever
# Save file has to be loaded at the same time everything else in the game is loading up
# Then the variables can be pulled from it

var shop: ShopManager = null

var _multiplier: float = 1.0


func _ready() -> void:
	_initialize()


func _initialize() -> void:
	shop = ShopManager.new()
	shop.item_bought.connect(_on_upgrade)


func _on_upgrade(item_type: ShopManager.ItemType, _count: int) -> void:
	if item_type != ShopManager.ItemType.DEBT:
		return
	var multiplier_variables := GameManager.shop.\
		get_upgrade_variables(item_type) as MultiplierVariables
	_multiplier = multiplier_variables.get_data()
	pass
