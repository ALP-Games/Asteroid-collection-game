class_name HookRopeEmitter extends RopeEmitter


func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if rope_segments.size() >= max_segment_count and connected_to_parent and not rope_target_reached:
		stop_emit()
