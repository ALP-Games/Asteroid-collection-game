class_name RopeSegment extends RigidBody3D

#const ROPE_SEGMENT = preload("res://actors/rope_segment.tscn")

@export var spawn_sounds: Array[AudioStream]
@export var sounds: Array[AudioStream]
@export var move_amount_to_sound: float = 7.0
@export var sound_pitch_curve: Curve
var pitch_random_offset: float = 0.03
var move_amount_buffer: float = 0
var velocity_buffer: PackedFloat32Array

@onready var rope_front: Node3D = $RopeFront
@onready var rope_end: Node3D = $RopeEnd
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	#_play_sound(true, true)
	#_play_spawn_sound(true)
	if spawn_sounds.size() > 0:
		var enter_pitch := 1.0
		var offset_amount := enter_pitch * pitch_random_offset
		var randomized_pitch := randf_range(enter_pitch - offset_amount, enter_pitch + offset_amount)
		
		var stream_to_play := _get_random_stream(spawn_sounds)
		var audio_stream := AudioStreamPlayer3D.new()
		add_child(audio_stream)
		_setup_sound(audio_stream, stream_to_play, global_position, randomized_pitch)


func _exit_tree() -> void:
	if spawn_sounds.size() > 0:
		var exit_pitch := 1.8
		var offset_amount := exit_pitch * pitch_random_offset
		var randomized_pitch := randf_range(exit_pitch - offset_amount, exit_pitch + offset_amount)
	
		var stream_to_play := _get_random_stream(spawn_sounds)
		var audio_stream := AudioStreamPlayer3D.new()
		get_tree().get_first_node_in_group("instantiated_root").add_child.call_deferred(audio_stream)
		_setup_sound(audio_stream, stream_to_play, global_position, randomized_pitch, -5.0)
	
	#_play_spawn_sound(false, randomized_pitch, -4.0)
	#_play_sound(false, true, 1.5, randomized_pitch)


static func _get_random_stream(audio_array: Array[AudioStream]) -> AudioStream:
	return audio_array[randi_range(0, audio_array.size() - 1)]


func _play_spawn_sound(track_position: bool = false, pitch_scale: float = 1.0, volume: float = 0.0) -> void:
	if spawn_sounds.size() <= 0:
		return
	var stream_to_play := spawn_sounds[randi_range(0, spawn_sounds.size() -1)]
	var audio_stream := AudioStreamPlayer3D.new()
	if track_position:
		add_child(audio_stream)
	else:
		get_tree().get_first_node_in_group("instantiated_root").add_child.call_deferred(audio_stream)
	#add_child(audio_stream)
	_setup_sound(audio_stream, stream_to_play, global_position, pitch_scale, volume)


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
	_setup_sound(audio_stream, stream_to_play, global_position, pitch_scale, volume)


static func _setup_sound(audio_stream: AudioStreamPlayer3D, stream: AudioStream, sound_pos: Vector3,\
						pitch_scale: float = 1.0, volume: float = 0.0) -> void:
	GameManager.call_deferred_callable((func():
		if not audio_stream or not audio_stream.is_inside_tree():
			return
		audio_stream.global_position = sound_pos
		audio_stream.stream = stream
		audio_stream.pitch_scale = pitch_scale
		audio_stream.volume_db = volume
		audio_stream.play()
		audio_stream.finished.connect(func():audio_stream.queue_free())
		))


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
			_play_sound(true, false, randomized_pitch, -7)


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
