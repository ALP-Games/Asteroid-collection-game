extends Node

signal credits_amount_changed(new_amount: int)

const VICTORY_LEVEL = preload("res://levels/game_end.tscn")

const MAX_PLAYING_ROPE_SOUNDS := 5

#const UPPER_ASTEROID_COUNT := 100
var current_asteroid_count := 0

var first_start: bool = true # I guess this has to come from save file or whatever
# Save file has to be loaded at the same time everything else in the game is loading up
# Then the variables can be pulled from it

var shop: ShopManager = null

var _multiplier: float = 1.0

var credist_amount: int = 0:
	set(value):
		credist_amount = value
		credits_amount_changed.emit(credist_amount)


func call_deferred_callable(callable: Callable) -> void:
	call_deferred("_run_callable", callable)


func _run_callable(callable: Callable) -> void:
	callable.call()


func _ready() -> void:
	_initialize()
	#upgrade_data.upgrade_incremented.connect(_check_victory)
	call_deferred("_reset_first_start")

func _reset_first_start() -> void:
	#credist_amount = 1000000
	first_start = false


func _initialize() -> void:
	credist_amount = 0
	shop = ShopManager.new()
	shop.item_bought.connect(_on_upgrade)
	current_asteroid_count = 0


func _on_upgrade(item_type: ShopManager.ItemType, _count: int) -> void:
	if item_type != ShopManager.ItemType.DEBT:
		return
	# MultiplierVariables
	var multiplier_variables := GameManager.shop.\
		get_upgrade_variables(item_type)
	_multiplier = multiplier_variables.get_data()
	if _count == 5:
		var shop_screen: ShopScreen = get_tree().get_first_node_in_group("shop_screen")
		shop_screen.add_end_game_prompt()


func reload() -> void:
	get_tree().paused = false
	_initialize()
	get_tree().reload_current_scene()


func get_multiplier() -> float:
	return _multiplier


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		var gizmo_manager := get_tree().get_first_node_in_group("gizmo_manager") as GizmoManager
		var camera := get_tree().get_first_node_in_group("camera") as FancyCameraArmature
		var mouse_world_position := camera.get_mouse_world_position()
		var node := Node3D.new()
		get_tree().get_first_node_in_group("instantiated_root").add_child(node)
		node.position = mouse_world_position
		
		var gizmo := gizmo_manager.get_count_up_gizmo(node, randi_range(34, 560))
		gizmo.finished_enabling.connect(func():node.queue_free())
		gizmo.enable()
