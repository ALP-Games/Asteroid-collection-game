class_name RopeEmitter extends Node3D

#const ROPE_SEGMENT = preload("res://actors/rope_segment.tscn")
@export var first_segment_scene: PackedScene = load("res://actors/anchor.tscn")
@export var rope_segment_scene: PackedScene = load("res://actors/rope_segment.tscn")

@export var shoot_force := 20000.0
@export var segment_spacing := 0.75
@export var max_segment_count := 30

var current_rope_segment := 0

var first_segment: RopeSegment = null
var last_segment: RopeSegment = null
var rope_shot := false

var rope_target_reached := false


func shoot_rope(target: Vector3) -> void:
	if rope_shot:
		return
	rope_shot = true
	look_at(target)
	var rope_segment := instantiate_new_rope_segment(global_transform)
	var direction := Vector3.FORWARD.rotated(Vector3.UP, rope_segment.rotation.y) 
	rope_segment.apply_central_force(direction * shoot_force)
	first_segment = rope_segment
	first_segment.target_reached.connect(on_rope_target_reached)
	last_segment = rope_segment


func on_rope_target_reached() -> void:
	rope_target_reached = true
	first_segment.target_reached.disconnect(on_rope_target_reached)


func instantiate_new_rope_segment(new_transform: Transform3D) -> RopeSegment:
	var new_segment: RopeSegment
	if current_rope_segment == 0:
		new_segment = first_segment_scene.instantiate()
	else:
		new_segment = rope_segment_scene.instantiate()
	get_tree().get_first_node_in_group("instantiated_root").add_child(new_segment)
	new_segment.global_transform = new_transform
	current_rope_segment += 1
	if not should_spawn_more_rope():
		new_segment.attach(get_parent(), global_position)
	return new_segment


func _physics_process(delta: float) -> void:
	_process_segment_addition()


func _process_segment_addition() -> void:
	if not last_segment:
		return
	while last_segment.global_position.distance_to(global_position) >= segment_spacing \
	and should_spawn_more_rope():
		add_segment_to_last()


func should_spawn_more_rope() -> bool:
	return current_rope_segment < max_segment_count or not rope_target_reached


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
