class_name Hook extends RopeSegment

signal target_reached(target: RigidBody3D, attachment_joint: Node3D)

const HOOK_HIT_ASTEROID = preload("uid://btw85yqdumem8")

var hooked := false

var parent_emitter: Emitter
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
		var hookable: HookableComponent = HookableComponent.core().get_from(colliding_object)
		if not hookable or hookable.hooked:
			parent_emitter.stop_emit()
			continue
		hookable.hook(self)
		#if colliding_object is Asteroid:
			#var velocity_direction := state.get_contact_local_velocity_at_position(index).normalized()
			#_instantiate_asteroid_hit(velocity_direction, contact_position)
		hooked = true
		attach_at_point(colliding_object, contact_position)
		target_reached.emit(colliding_object, hook_joint)
		hook_sound.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
		hook_sound.play()
		parent_emitter.emitter_done.connect(func():
			if hookable.hook_object == self:
				hookable.unhook(),
			CONNECT_ONE_SHOT)
		return
	#print("Contact count - ", contact_count)


func _instantiate_asteroid_hit(velocity_direction: Vector3, contact_position: Vector3) -> void:
	var asteroid_hit_effect := HOOK_HIT_ASTEROID.instantiate() as Node3D
	get_tree().get_first_node_in_group("instantiated_root").add_child(asteroid_hit_effect)
	asteroid_hit_effect.global_position = contact_position
	asteroid_hit_effect.look_at(contact_position - velocity_direction)
	var particles := asteroid_hit_effect.get_child(0) as GPUParticles3D
	particles.emitting = true
	particles.finished.connect(func():asteroid_hit_effect.queue_free())
	#asteroid_hit_effect.

func _on_child_entered_tree(node: Node) -> void:
	if hooked and node is PinJoint3D:
		hook_joint = node


func release_target() -> void:
	hooked = false
	if hook_joint:
		hook_joint.queue_free()
