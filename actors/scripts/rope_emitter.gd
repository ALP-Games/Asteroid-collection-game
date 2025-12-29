class_name RopeEmitter extends Emitter
# BIG SPAGET, FEATURES THINGS USED ONLY BY HOOK ROPE EMITER
# BETTER REFACTOR BOTH OF THE ROPE EMITTERS

#const MAX_TANGENTIAL_VELOCITY := 30.0
const MAX_ROPE_STRETCH := 1.95

#const ROPE_SEGMENT = preload("res://actors/rope_segment.tscn")
@export var first_segment_scene: PackedScene = load("res://actors/scenes/anchor.tscn")
@export var rope_segment_scene: PackedScene = load("res://actors/scenes/rope_segment.tscn")

@export var shoot_force := 20000.0
@export var segment_spacing := 0.75
@export var max_segment_count := 30
@export var retraction_force := 5000

var rope_max_length := 0.0
var rope_target: RigidBody3D
var target_attachment: Node3D

var rope_segments: Array[RopeSegment]
var first_segment: RopeSegment = null
var last_segment: RopeSegment = null
var rope_shot := false
var connected_to_parent := false
var retracting_rope := false
var rope_target_reached := false

#func _ready() -> void:
	#_parent = get_parent()


func emit(target: Vector3) -> void:
	if rope_shot:
		return
	rope_shot = true
	look_at(target)
	var rope_segment := instantiate_new_rope_segment(global_transform)
	var direction := Vector3.FORWARD.rotated(Vector3.UP, rope_segment.rotation.y)
	rope_segment.linear_velocity = direction * _parent.linear_velocity.dot(direction)
	rope_segment.apply_central_force(direction * shoot_force)
	first_segment = rope_segment
	last_segment = rope_segment


func stop_emit() -> void:
	retracting_rope = true
	if first_segment and first_segment.has_method("release_target"):
		first_segment.release_target()
	rope_target = null
	for rope_segment in rope_segments:
		rope_segment.disable_collision()
	_accelerate_last_segment_retraction()
	emitter_stopping.emit()


func break_rope() -> void:
	rope_target_reached = false
	connected_to_parent = false
	retracting_rope = false
	rope_shot = false
	rope_target = null
	
	while rope_segments.size() > 0:
		var rope_segment := rope_segments.pop_back() as RopeSegment
		rope_segment.queue_free()
	emitter_done.emit()


func instantiate_new_rope_segment(new_transform: Transform3D) -> RopeSegment:
	var new_segment: RopeSegment
	if rope_segments.size() == 0:
		new_segment = first_segment_scene.instantiate()
	else:
		new_segment = rope_segment_scene.instantiate()
	get_tree().get_first_node_in_group("instantiated_root").add_child(new_segment)
	rope_segments.append(new_segment)
	new_segment.global_transform = new_transform
	return new_segment


func _physics_process(_delta: float) -> void:
	if retracting_rope:
		_process_rope_retraction()
	elif rope_shot and not connected_to_parent and should_spawn_more_rope():
		_process_segment_addition()
	
	if rope_target:
		_enforce_rope_length()


func _enforce_rope_length() -> void:
	var current_distance := global_position.distance_to(target_attachment.global_position)
	
	if current_distance > MAX_ROPE_STRETCH * rope_max_length:
		break_rope()
		return
	
	if current_distance > rope_max_length:
		var total_mass := _parent.mass + rope_target.mass
		var parent_weight_ratio := rope_target.mass / total_mass
		var target_weight_ratio := _parent.mass / total_mass
		
		var direction := (global_position - rope_target.global_position).normalized()
		var stretch := pow((current_distance / rope_max_length), 4.0)
		
		var relative_velocity := _parent.linear_velocity - rope_target.linear_velocity
		var velocity_along_rope := relative_velocity.dot(direction)
		
		if velocity_along_rope <= 0:
			return
		
		var correction_velocity := direction * velocity_along_rope * stretch
		
		# not sure if modifying linear velocity directly is good like that
		# but I think I failed with apply central force before
		rope_target.linear_velocity += correction_velocity * target_weight_ratio 
		_parent.linear_velocity -= correction_velocity * parent_weight_ratio


func _process_segment_addition() -> void:
	_instantiate_continious_segments()
	
	if rope_segments.size() >= max_segment_count or rope_target_reached:
	#if not should_spawn_more_rope():
		connect_last_to_parent()


func _instantiate_continious_segments() -> void:
	while last_segment and last_segment.global_position.distance_to(global_position) >= segment_spacing:
		add_segment_to_last()


func _process_rope_retraction() -> void:
	if rope_segments.size() <= 0 and not last_segment:
		rope_target_reached = false
		connected_to_parent = false
		retracting_rope = false
		rope_shot = false
		emitter_done.emit()
		return
	
	if not _should_retract_last():
		_accelerate_last_segment_retraction()
	while _should_retract_last():
		_retract_last_segment() 


func _should_retract_last() -> bool:
	return last_segment and last_segment.global_position.distance_to(global_position) <= segment_spacing


func _accelerate_last_segment_retraction() -> void:
	if not last_segment and is_inside_tree():
		return
	var desired_direction := (global_position - last_segment.rope_end.global_position).normalized()
	var negative_force:= -(last_segment.linear_velocity.normalized() - desired_direction) * retraction_force
	last_segment.apply_force(desired_direction * retraction_force + negative_force, last_segment.rope_end.global_position)
	


func _retract_last_segment() -> void:
	last_segment.queue_free()
	last_segment = rope_segments.pop_back()
	#print("Last segment is first - ", last_segment == first_segment)


func should_spawn_more_rope() -> bool:
	return rope_segments.size() < max_segment_count or not rope_target_reached


func connect_last_to_parent() -> void:
	connected_to_parent = true
	if not last_segment:
		return
	last_segment.attach_at_point(_parent, global_position)


func segment_exited(body: Node3D) -> void:
	if body == last_segment:
		add_segment_to_last()


func add_segment_to_last() -> void:
	var prev_end := last_segment.rope_end.global_position
	var new_transform := Transform3D()
	new_transform.origin = prev_end
	var new_segment := instantiate_new_rope_segment(new_transform)
	new_segment.look_at(2 * prev_end - global_position, Vector3.UP)
	
	var offset := new_segment.rope_front.global_position - new_segment.global_position
	new_segment.global_position -= offset
	last_segment.attach(new_segment, new_segment.rope_front.global_position)
	last_segment = new_segment
