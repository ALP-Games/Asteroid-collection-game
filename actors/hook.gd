class_name Hook extends RopeSegment

signal target_reached(target: RigidBody3D, attachment_joint: Node3D)

var hooked := false

var hook_joint: PinJoint3D = null

@export var pitch_variation := 0.07
@onready var hook_sound: AudioStreamPlayer3D = $HookSound


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if hooked:
		return
	
	var contact_count := state.get_contact_count()
	for index in contact_count:
		var colliding_object := state.get_contact_collider_object(index)
		var contact_position := state.get_contact_local_position(index)
		var hookable := HookableComponent.core().get_from(colliding_object)
		if not hookable:
			continue
		hooked = true
		attach_at_point(colliding_object, contact_position)
		target_reached.emit(colliding_object, hook_joint)
		hook_sound.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
		hook_sound.play()
		return
	#print("Contact count - ", contact_count)


func _on_child_entered_tree(node: Node) -> void:
	if hooked and node is PinJoint3D:
		hook_joint = node


func release_target() -> void:
	hooked = true
	if hook_joint:
		hook_joint.queue_free()
