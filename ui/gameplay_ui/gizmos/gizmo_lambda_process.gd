class_name GizmoLambdaProcess extends IGizmo

var func_to_process: Callable = _do_nothing

var _process_callable: Callable = _do_nothing


func _do_nothing(_delta: float) -> void:
	pass


func _process(delta: float) -> void:
	_process_callable.call(delta)


func enable() -> void:
	_process_callable = func_to_process


func disable() -> void:
	_process_callable = _do_nothing


func is_enabled() -> bool:
	assert(func_to_process != _do_nothing)
	return _process_callable == func_to_process
