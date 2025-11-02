class_name Interaction extends PriorityQueueItem

# maybe interactions sould be position based?
# but then there might be problems with of the distance switching

var interaction_callable: Callable = _do_nothing

static func _do_nothing() -> void:
	pass


func interact(is_just_pressed: bool, is_pressed: bool) -> void:
	if is_just_pressed:
		_call_interaction()


func _call_interaction() -> void:
	interaction_callable.call()
