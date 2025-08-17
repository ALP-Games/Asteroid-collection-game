extends Node

const VICTORY_LEVEL = preload("res://levels/victory_level.tscn")

const MAX_PLAYING_ROPE_SOUNDS := 5

#const UPPER_ASTEROID_COUNT := 100
var current_asteroid_count := 0

var first_start: bool = true

signal credits_amount_changed(new_amount: int)

var upgrade_data: UpgradeData = null

var credist_amount: int = 0:
	set(value):
		credist_amount = value
		credits_amount_changed.emit(credist_amount)


func call_deferred_callable(callable: Callable) -> void:
	call_deferred("_run_callable", callable)


func _run_callable(callable: Callable) -> void:
	callable.call()


func _ready() -> void:
	upgrade_data.upgrade_incremented.connect(_check_victory)
	call_deferred("_reset_first_start")

func _reset_first_start() -> void:
	first_start = false


func _check_victory(upgrade_id: UpgradeData.UpgradeType, upgrade_level: int) -> void:
	if upgrade_id != UpgradeData.UpgradeType.DEBT:
		return
	if upgrade_level == 5:
		var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
		var timer_instance := Timer.new()
		instantiated_root.add_child(timer_instance)
		timer_instance.start(0.5)
		timer_instance.timeout.connect(func():get_tree().change_scene_to_packed(VICTORY_LEVEL))

func _init() -> void:
	_initialize()


func _initialize() -> void:
	credist_amount = 0
	upgrade_data = UpgradeData.new()
	current_asteroid_count = 0


func reload() -> void:
	get_tree().paused = false
	_initialize()
	get_tree().reload_current_scene()
