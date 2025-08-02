class_name EmitterManager extends Node3D

@export var max_emitter_amount := 5
@export var emitters: Array[PackedScene]

var instanced_emitters: Array[Emitter]

var index: int = 0

var stopping_emitters := false


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


func stop_emit() -> void:
	stopping_emitters = true
	for emitter in instanced_emitters:
		emitter.stop_emit()
	instanced_emitters.clear()
	stopping_emitters = false


func remove_from_instantiated(emitter: Emitter) -> void:
	if stopping_emitters:
		return
	var pos_in_array := instanced_emitters.find(emitter)
	if pos_in_array != -1:
		instanced_emitters.remove_at(pos_in_array)


func de_init_emitter(emitter: Emitter) -> void:
	remove_from_instantiated(emitter)
	emitter.queue_free()
