class_name Hook extends RopeSegment

var hooked := false


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if hooked:
		return
	
	var contact_count := state.get_contact_count()
	for index in contact_count:
		var colliding_object := state.get_contact_collider_object(index)
		var contact_position := state.get_contact_local_position(index)
		_attach_at_point(colliding_object, contact_position)
		hooked = true
		target_reached.emit()
		return
	#print("Contact count - ", contact_count)


#func _on_body_entered(body: Node) -> void:
	#if body is RigidBody3D:
		#print("Target reached - ", body.name)
		#target_reached.emit()
		
