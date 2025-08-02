class_name HookRopeEmitter extends RopeEmitter


func emit(target: Vector3) -> void:
	super(target)
	first_segment.target_reached.connect(on_rope_target_reached)


func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if rope_segments.size() >= max_segment_count and connected_to_parent and not rope_target_reached:
		stop_emit()


func on_rope_target_reached(target_object: RigidBody3D, attachment_joint: Node3D) -> void:
	rope_target_reached = true
	rope_target = target_object
	target_attachment = attachment_joint
	rope_max_length = global_position.distance_to(target_attachment.global_position)
	first_segment.target_reached.disconnect(on_rope_target_reached)
	target_object.tree_exiting.connect(stop_emit)
