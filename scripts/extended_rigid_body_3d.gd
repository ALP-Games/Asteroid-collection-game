class_name ExtendedRigidBody3D extends RigidBody3D

signal on_integrate_forces(state: PhysicsDirectBodyState3D)

func _ready() -> void:
	assert(contact_monitor && max_contacts_reported > 0, "ExtendedRigidBody3D needs contact monitor enabled and more than 0 contact should be reported!")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	on_integrate_forces.emit(state)
