class_name ShopZone extends RigidBody3D

const FOLDED_GRINDER = preload("uid://ylpkw2lvllxq")

@export var item_dispenser: ItemDispenser

@onready var handles: Array[Handle] = [$Handle, $Handle2, $Handle3]
@onready var decelerator_component: DeceleratorComponent = $DeceleratorComponent


var hooked_places_count: int = 0

var _total_mass: float = 0


var shop_interaction := Interaction.new() # Maybe interactions should be a resource?, then PriorityQueueItem has to be a resource
# Or maybe there should be a resource that would initialize an interaction priority queue item

func _init() -> void:
	shop_interaction.priority = 10
	shop_interaction.interaction_callable = _enable_shop_screen


func _ready() -> void:
	add_to_group("shop")
	for handle in handles:
		HookableComponent.core().invoke_on_component(handle, func(hookable: HookableComponent)->void:
			hookable.object_hooked.connect(_process_hooked_places_count.bind(true))
			hookable.object_unhooked.connect(_process_hooked_places_count.bind(false)))
	_total_mass = mass
	var handle_array: Array = get_meta(Handle.HANDLE_META, [])
	for handle: RigidBody3D in handle_array:
		_total_mass += handle.mass


func get_total_mass() -> float:
	return _total_mass


func _process_hooked_places_count(hooked: bool) -> void:
	if hooked:
		hooked_places_count += 1
		decelerator_component.decelerate = false
	else:
		hooked_places_count -= 1
	
	if hooked_places_count == 0:
		decelerator_component.decelerate = true


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
