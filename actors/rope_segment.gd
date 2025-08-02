class_name RopeSegment extends RigidBody3D

signal target_reached(target: RigidBody3D, attachment_joint: Node3D)

#const ROPE_SEGMENT = preload("res://actors/rope_segment.tscn")

@onready var rope_front: Node3D = $RopeFront
@onready var rope_end: Node3D = $RopeEnd
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	pass
	#var direction := Vector3.FORWARD.rotated(Vector3.UP, rotation.y) 
	#apply_central_force(direction * 100)


func disable_collision() -> void:
	collision_shape_3d.disabled = true


func attach(other: RigidBody3D, other_pin_point: Vector3) -> void:
	attach_at_point(other, (other_pin_point + rope_end.global_position) * 0.5)


func attach_at_point(other: RigidBody3D, point: Vector3) -> void:
	var pin_joint := PinJoint3D.new()
	add_child(pin_joint)
	pin_joint.global_position = point
	pin_joint.node_a = get_path()
	pin_joint.node_b = other.get_path()
