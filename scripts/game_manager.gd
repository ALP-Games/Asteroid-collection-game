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

@onready var _save_manager := SaveManager.new()
@onready var IS_RELEASE := OS.has_feature("release")

var save_data: SaveData

var credist_amount: int = 0:
	set(value):
		credist_amount = value
		if save_data:
			save_data.credist_amount = value
		credits_amount_changed.emit(credist_amount)


func _enter_tree() -> void:
	get_tree().root.child_entered_tree.connect(func(node: Node):
		if node.name == "World":
			node.ready.connect(func():
				shop.emit_items_bought()
				save_data.fresh_load = false
				, CONNECT_ONE_SHOT)
		)


func call_deferred_callable(callable: Callable) -> void:
	call_deferred("_run_callable", callable)


func _run_callable(callable: Callable) -> void:
	callable.call()


func _ready() -> void:
	save_data = _save_manager.load_save()
	_initialize()
	call_deferred("_reset_first_start")


func _reset_first_start() -> void:
	#credist_amount = 1000000
	first_start = false


func _on_upgrade(item_type: ShopManager.ItemType, _count: int) -> void:
	if item_type != ShopManager.ItemType.DEBT:
		return
	# MultiplierVariables
	var multiplier_variables = GameManager.shop.\
		get_upgrade_variables(item_type)
	_multiplier = multiplier_variables.get_data()
	if _count == 5:
		var shop_screen: ShopScreen = get_tree().get_first_node_in_group("shop_screen")
		shop_screen.add_end_game_prompt()


func _initialize() -> void:
	first_start = save_data.fresh_load
	credist_amount = save_data.credist_amount
	shop = ShopManager.new()
	shop.item_bought.connect(_on_upgrade)


func reload() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func reset_save() -> void:
	# delete save
	save_data = _save_manager.reset_save_data()
	_initialize()


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
