class_name CollisionSoundComponent extends Component

@export var sounds: Array[AudioStream]
@export var sound_cooldown := 0.05

var sound_on_cooldown: bool = false

static func core() -> ComponentCore:
	return ComponentCore.new(CollisionSoundComponent)


func _ready() -> void:
	var extended_rigid_body: ExtendedRigidBody3D = get_parent()
	extended_rigid_body.on_integrate_forces.connect(_on_integrate_forces)


func _on_integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if sound_on_cooldown:
		return
	var contact_count := state.get_contact_count()
	for contact_id in contact_count:
		var collider := state.get_contact_collider_object(contact_id)
		if collider is RopeSegment and not collider is Hook:
			continue
		if collider is PlayerShip or collider is Handle or collider is LatchMechanism:
			continue
		var collider_velocity := state.get_contact_collider_velocity_at_position(contact_id)
		var local_velocity := state.get_contact_local_velocity_at_position(contact_id)
		var normal := state.get_contact_local_normal(contact_id)
		var relative_velocity := collider_velocity - local_velocity
		var velocity_length: float = abs(relative_velocity.dot(normal))
		#print("Collision velocity length - ", velocity_length)
		var contact_position := state.get_contact_local_position(contact_id)
		_instantiate_collision_sound(contact_position, velocity_length)


func _instantiate_collision_sound(contact_position: Vector3, strength: float) -> void:
	if strength < 3.0:
		return
	var sound_player := AudioStreamPlayer3D.new()
	add_child(sound_player)
	sound_player.global_position = contact_position
	var sound_index := randi_range(0, sounds.size() - 1)
	sound_player.stream = sounds[sound_index]
	sound_player.play()
	sound_player.finished.connect(func():sound_player.queue_free())
	sound_on_cooldown = true
	var timer := get_tree().create_timer(sound_cooldown, false, true)
	timer.timeout.connect(func():sound_on_cooldown=false)
