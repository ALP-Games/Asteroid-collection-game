class_name ShopZone extends Node3D

const FOLDED_GRINDER = preload("uid://ylpkw2lvllxq")

@export var item_dispenser: ItemDispenser

@onready var handles: Array[Handle] = [$Handle, $Handle2, $Handle3]

var shop_interaction := Interaction.new() # Maybe interactions should be a resource?, then PriorityQueueItem has to be a resource
# Or maybe there should be a resource that would initialize an interaction priority queue item

func _init() -> void:
	shop_interaction.priority = 10
	shop_interaction.interaction_callable = _enable_shop_screen

# TODO: shop interact action should be added to queue

func _on_area_3d_body_entered(body: Node3D) -> void:
	InteractorComponent.core().invoke_on_component(body, _add_interaction)
	#if body is PlayerShip:
		#body.in_shop_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	# but this should only be removed once the shop is not visible
	InteractorComponent.core().invoke_on_component(body, _remove_interaction)
	#if body is PlayerShip:
		#body.in_shop_range = false


func _add_interaction(interaction_component: InteractorComponent) -> void:
	interaction_component.add_interaction(shop_interaction)


func _remove_interaction(interaction_component: InteractorComponent) -> void:
	var shop_screen: ShopScreen = get_tree().get_first_node_in_group("shop_screen")
	if shop_screen and shop_screen.visible:
		shop_screen.shop_visibilit_changed.connect(func(_visble: bool):
			interaction_component.remove_interaction(shop_interaction), CONNECT_ONE_SHOT)
	else:
		interaction_component.remove_interaction(shop_interaction)


func _enable_shop_screen() -> void:
	var shop_screen: ShopScreen = get_tree().get_first_node_in_group("shop_screen")
	shop_screen.toggle_shop()
	if GameManager.shop.item_bought.is_connected(_item_bought):
		GameManager.shop.item_bought.disconnect(_item_bought)
	else:
		GameManager.shop.item_bought.connect(_item_bought)


func enable_handles() -> void:
	handles.all(func(handle):
		handle.start_enablement_animation()
		return true)


func _item_bought(item_type: ShopManager.ItemType, _count: int) -> void:
	if item_type == ShopManager.ItemType.GRINDER:
		item_dispenser.add_item_to_dispense(FOLDED_GRINDER)
		pass
