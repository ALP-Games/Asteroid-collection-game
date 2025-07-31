class_name RopeEmitter extends Node3D

const ROPE_SEGMENT = preload("res://actors/rope_segment.tscn")
@onready var area_3d: Area3D = $Area3D

@export var shoot_force := 2000.0
@export var max_segment_count := 15

var current_rope_segment := 0

var first_segment: RopeSegment = null
var last_segment: RopeSegment = null
var rope_shot := false
var last_segment_entered_detection := false


func shoot_rope(target: Vector3) -> void:
	if rope_shot:
		return
	rope_shot = true
	look_at(target)
	var rope_segment := instantiate_new_rope_segment(global_transform)
	var direction := Vector3.FORWARD.rotated(Vector3.UP, rope_segment.rotation.y) 
	rope_segment.apply_central_force(direction * shoot_force)
	first_segment = rope_segment
	last_segment = rope_segment
	#area_3d.body_entered.connect(check_last_added)
	area_3d.body_exited.connect(segment_exited)


func instantiate_new_rope_segment(new_transform: Transform3D) -> RopeSegment:
	var rope_segment := ROPE_SEGMENT.instantiate() as RopeSegment
	rope_segment.global_transform = new_transform
	rope_segment.add_to_group("instantiated")
	get_tree().get_root().add_child(rope_segment)
	current_rope_segment += 1
	if current_rope_segment >= max_segment_count:
		rope_segment.attach(get_parent())
		#area_3d.body_entered.disconnect(check_last_added)
		area_3d.body_exited.disconnect(segment_exited)
	else:
		last_segment_entered_detection = false
	return rope_segment


#func _physics_process(delta: float) -> void:
	#if not last_segment_entered_detection:
		#add_segment_to_last()


#func check_last_added(body: Node3D) -> void:
	#if body == last_segment:
		#last_segment_entered_detection = true


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
	last_segment.attach(new_segment)
	last_segment = new_segment
