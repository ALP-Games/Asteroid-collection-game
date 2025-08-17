class_name HookRopeEmitter extends RopeEmitter

@export var min_segment_count: int = 7
@export var segment_length: float = 1.0

var _internal_target_reached: bool = false

func emit(target: Vector3) -> void:
	super(target)
	emitter_done.connect(reset_vars_on_emitter_done)
	first_segment.target_reached.connect(on_rope_target_reached)


func reset_vars_on_emitter_done() -> void:
	_internal_target_reached = false


func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if rope_segments.size() >= max_segment_count and connected_to_parent and not _internal_target_reached:
		stop_emit()
	elif _internal_target_reached and _min_segment_count_reached():
		rope_target_reached = true


func on_rope_target_reached(target_object: RigidBody3D, attachment_joint: Node3D) -> void:
	_internal_target_reached = true
	rope_target = target_object
	target_attachment = attachment_joint
	first_segment.target_reached.disconnect(on_rope_target_reached)
	target_object.tree_exiting.connect(stop_emit)	
	if not _min_segment_count_reached():
		rope_max_length = min_segment_count * segment_length
		return
	rope_target_reached = true
	rope_max_length = rope_segments.size() * segment_length


func _min_segment_count_reached() -> bool:
	return rope_segments.size() >= min_segment_count
