class_name Hook extends RopeSegment

var hooked := false

var hook_joint: PinJoint3D = null 

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if hooked:
		return
	
	var contact_count := state.get_contact_count()
	for index in contact_count:
		var colliding_object := state.get_contact_collider_object(index)
		var contact_position := state.get_contact_local_position(index)
		hooked = true
		attach_at_point(colliding_object, contact_position)
		target_reached.emit(colliding_object, hook_joint)
		return
	#print("Contact count - ", contact_count)


func _on_child_entered_tree(node: Node) -> void:
	if hooked and node is PinJoint3D:
		print("Hook success")
		hook_joint = node


func release_target() -> void:
	hooked = true
	if hook_joint:
		hook_joint.queue_free()
