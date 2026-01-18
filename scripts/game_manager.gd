extends Node

signal credits_amount_changed(new_amount: int)
signal game_state_changed()

const WORLD_SCENE = preload("uid://pg35x7vyq772")
const VICTORY_SCENE = preload("res://levels/game_end.tscn")

const MAX_PLAYING_ROPE_SOUNDS := 5

var current_asteroid_count := 0

var shop: ShopManager = null

var _state: Game.State:
	set(value):
		_state = value
		game_state_changed.emit()
var _multiplier: float = 1.0
var _global_deinit: bool = false
var _scene_loading: bool = false

@onready var IS_RELEASE := OS.has_feature("release")
@onready var _save_manager := SaveManager.new()

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
				_scene_loading = true
				_global_deinit = false
				var message_container: MessageContainer = get_tree().get_first_node_in_group(MessageContainer.GROUP)
				message_container.add_message(_save_manager._save_path, 10)
				shop.emit_items_bought()
				var instantiate_asteroids := save_data.fresh_load
				save_data.fresh_load = false
				save_data.instantiate_saved_objects()
				_scene_loading = false
				if instantiate_asteroids:
					var asteroid_spawner := node.get_child(0) as AsteroidSpawner
					asteroid_spawner.generate_gameplay_asteroids()
					, CONNECT_ONE_SHOT)
		)


func call_deferred_callable(callable: Callable) -> void:
	call_deferred("_run_callable", callable)


func _run_callable(callable: Callable) -> void:
	callable.call()


func _ready() -> void:
	_state = Game.State.GAMEPLAY
	save_data = _save_manager.load_save()
	_initialize()
	set_process(not IS_RELEASE)


func _on_upgrade(item_type: ShopManager.ItemType, _count: int) -> void:
	if item_type != ShopManager.ItemType.DEBT:
		return
	# MultiplierVariables
	var multiplier_variables = GameManager.shop.\
		get_upgrade_variables(item_type)
	_multiplier = multiplier_variables.get_data()
	if _count > 0 and not _scene_loading:
		var message_container: MessageContainer = get_tree().get_first_node_in_group(MessageContainer.GROUP)
		message_container.add_message("Cash multiplier increased to " + str(_multiplier) + "x")
	if _count == 5:
		var shop_screen: ShopScreen = get_tree().get_first_node_in_group("shop_screen")
		shop_screen.add_end_game_prompt()


func _initialize() -> void:
	credist_amount = save_data.credist_amount
	shop = ShopManager.new()
	shop.item_bought.connect(_on_upgrade)


func reload() -> void:
	_global_deinit = true
	get_tree().paused = false
	get_tree().reload_current_scene()


func reset_save() -> void:
	# delete save
	save_data = _save_manager.reset_save_data()
	_initialize()


func quit_game() -> void:
	_global_deinit = true
	get_tree().quit()


func load_gameplay() -> void:
	_global_deinit = true
	_state = Game.State.GAMEPLAY
	get_tree().change_scene_to_packed(WORLD_SCENE)


func load_victory_level() -> void:
	_save_manager.sync_save()
	_global_deinit = true
	_state = Game.State.VICTORY_SCREEN
	get_tree().change_scene_to_packed(VICTORY_SCENE)


func get_multiplier() -> float:
	return _multiplier


func is_global_deinit() -> bool:
	return _global_deinit


func get_state() -> Game.State:
	return _state


# Debug only
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
