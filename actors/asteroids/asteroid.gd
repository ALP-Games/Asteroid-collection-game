class_name Asteroid extends RigidBody3D

signal scale_changed(new_scale: float)

const ASTEROID_COLLISION_EFFECT = preload("uid://btw85yqdumem8")
const ROCK_EXPLOSION = preload("res://actors/effects/rock_explosion.tscn")
const ASTEROID_CRUNCH_SOUND = preload("res://actors/effects/asteroid_crunch_sound.tscn")

const COLLISION_SFX = [preload("uid://cv0k3jybqsgsa"), preload("uid://dn4hhhuf5cp4y"),
						preload("uid://bjl31cg5jv270"), preload("uid://b76utayb5dtym")]

const MIN_COLLISION_LENGTH = 5.5
const SPEED_SCALE_MULTIPLIER = 0.25
const MIN_SPEED_SCALE = 0.5
const PARTICLES_MULTIPLIER = 0.5

const DEFAULT_SCALE: float = 1.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var asteroid_scale: float = 1.0

@export var initial_value: float = 10.0
@export var weight_value_multiplier: float = 0.1
@export var default_density: float = 100.0

var init_on_ready := false
## Maybe works

func _ready() -> void:
	if not init_on_ready:
		return
	var change := asteroid_scale / DEFAULT_SCALE
	mesh_instance_3d.scale *= change
	collision_shape_3d.scale *= change


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var contact_count := state.get_contact_count()
	for contact_id in contact_count:
		var collider := state.get_contact_collider_object(contact_id)
		if collider is RopeSegment and not collider is Hook:
			continue
		var collider_velocity := state.get_contact_collider_velocity_at_position(contact_id)
		var local_velocity := state.get_contact_local_velocity_at_position(contact_id)
		var normal := state.get_contact_local_normal(contact_id)
		var relative_velocity := collider_velocity - local_velocity
		var velocity_length: float = abs(relative_velocity.dot(normal))
		#print("Collision velocity length - ", velocity_length)
		var contact_position := state.get_contact_local_position(contact_id)
		_instantiate_asteroid_hit_sound(contact_position, velocity_length)
		if velocity_length < MIN_COLLISION_LENGTH:
			continue
		var collision_direction := relative_velocity.normalized()
		var collision_strength := velocity_length / MIN_COLLISION_LENGTH
		_instantiate_asteroid_hit(collision_direction, contact_position, collision_strength)


func _instantiate_asteroid_hit(velocity_direction: Vector3, contact_position: Vector3, strength: float) -> void:
	var asteroid_hit_effect := ASTEROID_COLLISION_EFFECT.instantiate() as Node3D
	add_child(asteroid_hit_effect)
	#asteroid_hit_effect.scale *= asteroid_scale
	#get_tree().get_first_node_in_group("instantiated_root").add_child(asteroid_hit_effect)
	asteroid_hit_effect.global_position = contact_position
	if velocity_direction == Vector3.ZERO:
		return
	asteroid_hit_effect.look_at(contact_position - velocity_direction)
	var particles := asteroid_hit_effect.get_child(0) as GPUParticles3D
	particles.amount *= PARTICLES_MULTIPLIER * strength
	particles.speed_scale *= SPEED_SCALE_MULTIPLIER * strength
	particles.speed_scale = max(particles.speed_scale, MIN_SPEED_SCALE)
	particles.emitting = true
	particles.finished.connect(func():asteroid_hit_effect.queue_free())


func _instantiate_asteroid_hit_sound(contact_position: Vector3, strength: float) -> void:
	if strength < 3.0:
		return
	var sound_player := AudioStreamPlayer3D.new()
	add_child(sound_player)
	sound_player.global_position = contact_position
	var sound_index := randi_range(0, COLLISION_SFX.size() - 1)
	sound_player.stream = COLLISION_SFX[sound_index]
	sound_player.play()
	sound_player.finished.connect(func():sound_player.queue_free())


# this scale is a diameter
func set_mass_with_scale(new_scale: float) -> void:
	var change := new_scale / asteroid_scale
	if is_node_ready():
		mesh_instance_3d.scale *= change
		collision_shape_3d.scale *= change
	else:
		init_on_ready = true
	asteroid_scale *= change
	mass = default_density * pow(new_scale, 3)
	scale_changed.emit(asteroid_scale)


func get_asteroid_value() -> int:
	return initial_value + (mass * weight_value_multiplier) as int


func destroy_asteroid() -> void:
	var destroy_effect := ROCK_EXPLOSION.instantiate()
	get_tree().get_first_node_in_group("instantiated_root").add_child(destroy_effect)
	destroy_effect.global_position = global_position
	var particles := destroy_effect.get_child(0) as GPUParticles3D
	particles.amount *= asteroid_scale
	particles.emitting = true
	particles.finished.connect(func():destroy_effect.queue_free())
	
	var destroy_sound := ASTEROID_CRUNCH_SOUND.instantiate() as AudioStreamPlayer3D
	get_tree().get_first_node_in_group("instantiated_root").add_child(destroy_sound)
	destroy_sound.global_position = global_position
	destroy_sound.finished.connect(func():destroy_sound.queue_free())
	(get_tree().get_first_node_in_group("gizmo_manager") as GizmoManager).get_count_up_gizmo(self, get_asteroid_value()).enable()
	GameManager.save_data.asteroids_ground += 1
	queue_free()
