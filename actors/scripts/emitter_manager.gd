class_name EmitterManager extends Node3D

@export var max_emitter_amount := 1
@export var emitters: Array[PackedScene]

var instanced_emitters: Array[Emitter]

var index: int = 0

var stopping_emitters := false

# this variable produces a lot of coupled code
var hook_ui: HookUI

func _ready() -> void:
	hook_ui = get_tree().get_first_node_in_group("hook_ui")
	call_deferred("_update_hook_ui")
	GameManager.shop.item_bought.connect(_hooks_upgraded)


func _update_hook_ui() -> void:
	hook_ui.set_hook_count(instanced_emitters.size(), max_emitter_amount)


func _hooks_upgraded(item_type: ShopManager.ItemType, count: int) -> void:
	if item_type != ShopManager.ItemType.HOOK_COUNT:
		return
	max_emitter_amount = count + 1
	_update_hook_ui()


func emit(target: Vector3) -> void:
	if instanced_emitters.size() >= max_emitter_amount:
		return
	var emitter_isntance := emitters[index].instantiate() as Emitter
	add_child(emitter_isntance)
	emitter_isntance.set_parent(get_parent())
	emitter_isntance.emit(target)
	emitter_isntance.emitter_stopping.connect(remove_from_instantiated.bind(emitter_isntance), CONNECT_ONE_SHOT)
	emitter_isntance.emitter_done.connect(de_init_emitter.bind(emitter_isntance), CONNECT_ONE_SHOT)
	instanced_emitters.append(emitter_isntance)
	_update_hook_ui()


func stop_emit() -> void:
	stopping_emitters = true
	for emitter in instanced_emitters:
		emitter.stop_emit()
	instanced_emitters.clear()
	stopping_emitters = false
	_update_hook_ui()


func remove_from_instantiated(emitter: Emitter) -> void:
	if stopping_emitters:
		return
	instanced_emitters.erase(emitter)
	_update_hook_ui()


func de_init_emitter(emitter: Emitter) -> void:
	remove_from_instantiated(emitter)
	emitter.queue_free()
