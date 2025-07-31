class_name RopeSegment extends RigidBody3D

const ROPE_SEGMENT = preload("res://actors/rope_segment.tscn")

@onready var rope_front: Node3D = $RopeFront
@onready var rope_end: Node3D = $RopeEnd


func _ready() -> void:
	pass
	#var direction := Vector3.FORWARD.rotated(Vector3.UP, rotation.y) 
	#apply_central_force(direction * 100)


func attach(other: RigidBody3D) -> void:
	var pin_joint := PinJoint3D.new()
	add_child(pin_joint)
	if other is RopeSegment:
		pin_joint.global_position = (other.rope_front.global_position + rope_end.global_position) * 0.5
	else:
		#pin_joint.global_position = other.global_position
		pin_joint.global_position = (other.global_position + rope_end.global_position) * 0.5
	pin_joint.node_a = get_path()
	pin_joint.node_b = other.get_path()
	
