class_name RopeSegment extends RigidBody3D

signal target_reached(target: RigidBody3D, attachment_joint: Node3D)

#const ROPE_SEGMENT = preload("res://actors/rope_segment.tscn")

@export var sounds: Array[AudioStreamOggVorbis]
@export var move_amount_to_sound: float = 7.0
@export var sound_pitch_curve: Curve
var pitch_random_offset: float = 0.03
var move_amount_buffer: float = 0
var velocity_buffer: PackedFloat32Array

@onready var rope_front: Node3D = $RopeFront
@onready var rope_end: Node3D = $RopeEnd
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_play_sound(true, true)
	pass


func _exit_tree() -> void:
	pass
	#call_deferred("_add_and_play_sound")
	_play_sound(false, true, 1.5, 2.0)
	#GameManager.call_deferred_callable(_add_and_play_sound)


func _play_sound(track_position: bool = false, force: bool = false,\
				pitch_scale: float = 1.0, volume: float = 0.0) -> void:
	if sounds.size() <= 0:
		return
	if get_tree().get_nodes_in_group("rope_sound").size() >= GameManager.MAX_PLAYING_ROPE_SOUNDS and not force:
		return
	var stream_to_play := sounds[randi_range(0, sounds.size() -1)]
	var audio_stream := AudioStreamPlayer3D.new()
	audio_stream.add_to_group("rope_sound")
	if track_position:
		add_child(audio_stream)
	else:
		get_tree().get_first_node_in_group("instantiated_root").add_child.call_deferred(audio_stream)
	GameManager.call_deferred_callable((func(position: Vector3):
		audio_stream.global_position = position
		audio_stream.stream = stream_to_play
		audio_stream.pitch_scale = pitch_scale
		audio_stream.volume_db = volume
		audio_stream.play()
		audio_stream.finished.connect(func():audio_stream.queue_free())
		).bind(global_position))


func _physics_process(delta: float) -> void:
	var current_velocity_amount := linear_velocity.length()
	velocity_buffer.append(current_velocity_amount)
	move_amount_buffer += current_velocity_amount * delta
	if move_amount_buffer >= move_amount_to_sound:
		move_amount_buffer -= move_amount_to_sound
		var velocity_average: float = 0.0
		for velocity_entry in velocity_buffer:
			velocity_average += velocity_entry
		velocity_average /= velocity_buffer.size()
		velocity_buffer.clear()
		if sound_pitch_curve:
			var pitch_scale := sound_pitch_curve.sample(velocity_average)
			var offset_amount := pitch_scale * pitch_random_offset
			var randomized_pitch := randf_range(pitch_scale - offset_amount, pitch_scale + offset_amount)
			_play_sound(true, false, randomized_pitch, -5)


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
