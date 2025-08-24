class_name PlayerShip extends RigidBody3D

const MAX_JET_VELOCITY := 25.0
const JET_MIN_SCALE := 0.01
const JET_MAX_SCALE := 1.0

@export var max_velocity: float = 30
@export_group("Weight Based Max Velocity")
@export var weight_based_velocity_enabled: bool = false
@export var drag_coefficient: float = 600

@export_group("Movement")
@export var starting_acceleration: float = 20
@export var starting_reverse_acceleration: float = 10
@export var turn_acceleration: float = 10.0
@export var max_turn_speed: float = 4.0

@export var starting_linear_amount_stop: float = 20
@export var stop_angular_amount: float = 10

@export_group("Collisions")
@export_subgroup("Stun")
@export var starting_min_collision_force_for_stun: float = 4000
@export var collision_stun_time_curve: Curve
@export_subgroup("Sound")
@export var min_collision_force_for_sound: float = 2000
@export var collision_sounds: Array[AudioStream]
@export var collision_sound_curve: Curve
# But maybe pitch variation should come from force or something
# small collision = very high pitched sound
@export var collision_pitch_variation := 0.07

@export_group("Stabilization Warning")
@export var stabilization_warning_multiple: float = 2.0
@export var destabilized_time: float = 0.25
var destabilized_elapsed := 0.0

@export_group("Misc")
@export var max_graphics_tilt: float = 45.0

@export var jet_sound_fade_out_duration: float = 0.2

@onready var min_collision_force_for_stun := starting_min_collision_force_for_stun

@onready var starting_mass: float = mass
@onready var thrust_force: float = starting_acceleration * starting_mass
@onready var reverse_force: float = starting_reverse_acceleration * starting_mass
@onready var stop_linear_amount: float = starting_linear_amount_stop * starting_mass

@onready var graphics: Node3D = $Graphics
@onready var emitter_manager: EmitterManager = $EmitterManager

@onready var jet_beam: Node3D = $Graphics/JetBeam
@onready var jet_beam_2: Node3D = $Graphics/JetBeam2

@onready var jet_effect: AudioStreamPlayer3D = $JetEffect
@onready var sound_default_volume: float = jet_effect.volume_db
var sound_fade_out_tween: Tween

@onready var rcs_thrust_loop: AudioStreamPlayer3D = $RCSThrustLoop
@onready var rcs_default_volume: float = rcs_thrust_loop.volume_db
var rcs_fade_out_tween: Tween

@onready var collision_sounds_player: AudioStreamPlayer3D = $CollisionSoundsPlayer
@onready var collision_default_volume: float = collision_sounds_player.volume_db

@onready var rcs_thrusters_left_trun: Array[GPUParticles3D] = [$Graphics/RCSFrontRight, $Graphics/RCSBackLeft]
@onready var rcs_thrusters_right_trun: Array[GPUParticles3D] = [$Graphics/RCSFrontLeft, $Graphics/RCSBackRight]

var player_stunned := false
var in_shop_range := false


func _ready() -> void:
	GameManager.upgrade_data.upgrade_incremented.connect(_on_upgrade)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var contact_count := state.get_contact_count()
	for contact_id in contact_count:
		#state.get_velocity_at_local_position()
		var vel_self := state.get_contact_local_velocity_at_position(contact_id)
		var vel_other := state.get_contact_collider_velocity_at_position(contact_id)
		var vel_relative := vel_self - vel_other
		var normal := state.get_contact_local_normal(contact_id)
		var speed_relative := vel_relative.dot(normal)
		var other := state.get_contact_collider_object(contact_id)
		var reduced_mass: float
		if other is RigidBody3D:
			var other_mass: float = other.mass
			reduced_mass = (mass * other_mass) / (mass + other_mass)
		else:
			reduced_mass = mass
		#print("Reduced mass - ", reduced_mass)
		var impulse_magnitude: float = abs(speed_relative) * reduced_mass
		_stun_player_on_collision(impulse_magnitude)
		_play_collision_sound(impulse_magnitude)


func _stun_player_on_collision(impulse_magnitude: float) -> void:
	if impulse_magnitude >= min_collision_force_for_stun:
		#print("Impulse magnitude - ", impulse_magnitude)
		player_stunned = true
		var difference := impulse_magnitude / min_collision_force_for_stun
		var stun_duration := collision_stun_time_curve.sample(difference)
		get_tree().create_timer(stun_duration).timeout.connect(func():
			player_stunned = false
			)
		(get_tree().get_first_node_in_group("collision_warning") as CollisionWarning).set_timer_and_show(stun_duration)


func _play_collision_sound(impulse_magnitude: float) -> void:
	if impulse_magnitude >= min_collision_force_for_sound:
		var difference := impulse_magnitude / min_collision_force_for_sound
		var volume_multiplier := collision_sound_curve.sample(difference)
		var chosen_sound := randi_range(0, collision_sounds.size() - 1)
		var collision_sound_player_instance := AudioStreamPlayer3D.new()
		add_child(collision_sound_player_instance)
		collision_sound_player_instance.finished.connect(func():collision_sound_player_instance.queue_free())
		collision_sound_player_instance.stream = collision_sounds[chosen_sound]
		collision_sound_player_instance.volume_db = collision_default_volume * volume_multiplier
		collision_sound_player_instance.pitch_scale = randf_range(1 - collision_pitch_variation, 1 + collision_pitch_variation)
		collision_sound_player_instance.play()


func _play_jet_sound(play: bool) -> void:
	_play_sound_effect(play, jet_effect, sound_fade_out_tween, sound_default_volume)


func _play_rcs_sound(play: bool) -> void:
	if play:
		if not rcs_thrust_loop.playing and not rcs_thrust_loop.stream_paused:
			rcs_thrust_loop.play()
		rcs_thrust_loop.stream_paused = false
	else:
		rcs_thrust_loop.stream_paused = true


func _play_sound_effect(play: bool, sound_stream: AudioStreamPlayer3D, sound_tween: Tween, default_volume: float) -> void:
	if play:
		if sound_tween and sound_tween.is_valid():
			sound_tween.kill()
		if not sound_stream.playing and not sound_stream.stream_paused:
			sound_stream.play()
		sound_stream.volume_db = default_volume # maybe need a fade in tween?, or maybe even spawn the stream player?
		sound_stream.stream_paused = false
	else:
		if sound_stream.playing and not sound_stream.stream_paused:
			fade_out_sfx(sound_stream, sound_tween)

func fade_out_sfx(sound_stream: AudioStreamPlayer3D, sound_tween: Tween) -> void:
	if sound_tween and sound_tween.is_valid():
		return
	sound_tween = create_tween()
	sound_tween.tween_property(sound_stream, "volume_db", -80.0, jet_sound_fade_out_duration)
	sound_tween.tween_callback(func():sound_stream.stream_paused = true)


func _on_upgrade(upgrade_id: UpgradeData.UpgradeType, upgrade_level: int) -> void:
	match upgrade_id:
		UpgradeData.UpgradeType.ENGINE_POWER:
			_thrusters_upgraded(upgrade_level)
		UpgradeData.UpgradeType.WEIGHT:
			_weight_upgraded(upgrade_level)


func _thrusters_upgraded(upgrade_level: int) -> void:
	match upgrade_level:
		0:
			stop_linear_amount = starting_mass * starting_linear_amount_stop
			thrust_force = starting_mass * starting_acceleration
			reverse_force = starting_mass * starting_reverse_acceleration
		1:
			stop_linear_amount = starting_mass * 30.0
			thrust_force = starting_mass * 25.0
			reverse_force = starting_mass * 10.0
		2:
			stop_linear_amount = starting_mass * 50.0
			thrust_force = starting_mass * 40.0
			reverse_force = starting_mass * 25.0
		3:
			stop_linear_amount = starting_mass * 100.0
			thrust_force = starting_mass * 75.0
			reverse_force = starting_mass * 45.0
		4:
			stop_linear_amount = starting_mass * 160.0
			thrust_force = starting_mass * 130.0
			reverse_force = starting_mass * 75.0
		5:
			stop_linear_amount = starting_mass * 250.0
			thrust_force = starting_mass * 190.0
			reverse_force = starting_mass * 150.0


func _weight_upgraded(upgrade_level: int) -> void:
	match upgrade_level:
		0:
			mass = starting_mass
			min_collision_force_for_stun = starting_min_collision_force_for_stun
		1:
			mass = starting_mass + (500*2)
			min_collision_force_for_stun = starting_min_collision_force_for_stun * (mass / starting_mass)
		2:
			mass = starting_mass + (500*4)
			min_collision_force_for_stun = starting_min_collision_force_for_stun * (mass / starting_mass)
		3:
			mass = starting_mass + (500*8)
			min_collision_force_for_stun = starting_min_collision_force_for_stun * (mass / starting_mass)
		4:
			mass = starting_mass + (500*16)
			min_collision_force_for_stun = starting_min_collision_force_for_stun * (mass / starting_mass)
		5:
			mass = starting_mass + (500*32)
			min_collision_force_for_stun = starting_min_collision_force_for_stun * (mass / starting_mass)


func _enable_rcs_thruster_effect(rotation_input: float) -> void:
	rcs_thrusters_left_trun
	rcs_thrusters_right_trun
	if rotation_input < 0:
		for thruster in rcs_thrusters_left_trun:
			thruster.emitting = true
		for thruster in rcs_thrusters_right_trun:
			thruster.emitting = false
	elif rotation_input > 0:
		for thruster in rcs_thrusters_left_trun:
			thruster.emitting = false
		for thruster in rcs_thrusters_right_trun:
			thruster.emitting = true
	else:
		for thruster in rcs_thrusters_left_trun:
			thruster.emitting = false
		for thruster in rcs_thrusters_right_trun:
			thruster.emitting = false


func _process(_delta: float) -> void:
	var turn_ratio := angular_velocity.y / max_turn_speed
	graphics.rotation.z = deg_to_rad(max_graphics_tilt) * turn_ratio
	
	#var velocity_ration := linear_velocity.length() / MAX_JET_VELOCITY
	var jet_scale := remap(linear_velocity.length(), 0, MAX_JET_VELOCITY, JET_MIN_SCALE, JET_MAX_SCALE)
	jet_beam.scale = Vector3(jet_scale, jet_scale, jet_scale)
	jet_beam_2.scale = Vector3(jet_scale, jet_scale, jet_scale)


func _physics_process(delta: float) -> void:
	if abs(angular_velocity.y) >= max_turn_speed * stabilization_warning_multiple:
		destabilized_elapsed += delta
		if destabilized_elapsed >= destabilized_time:
			(get_tree().get_first_node_in_group("stabilization_warinig") as WarningBox).show_warning()
	else:
		var stabilization_warning := (get_tree().get_first_node_in_group("stabilization_warinig") as WarningBox)
		if stabilization_warning.is_shown():
			stabilization_warning.hide_warning()
		destabilized_elapsed = 0.0
	
	var shop_screen: Control = get_tree().get_first_node_in_group("shop_screen")
	
	if (shop_screen.visible or in_shop_range) and Input.is_action_just_pressed("open_shop"):
		shop_screen.visible = !shop_screen.visible
	
	if shop_screen.visible:
		return
	
	var thrust_input: bool = false
	var reverse_input: bool = false
	var stop_input: bool = false
	var rotation_input: float = 0.0
	
	if not player_stunned:
		thrust_input = Input.is_action_pressed("thrust")
		reverse_input = Input.is_action_pressed("reverse")
		stop_input = Input.is_action_pressed("stop")
		rotation_input = Input.get_axis("rot_left", "rot_right")
	
	var movement_input_held := thrust_input or reverse_input or stop_input #or not is_zero_approx(rotation_input)
	_play_jet_sound(movement_input_held)
	_play_rcs_sound(not is_zero_approx(rotation_input))
	print("Rotation input - ", rotation_input)
	
	if Input.is_action_just_pressed("action"):
		var camera := get_tree().get_first_node_in_group("camera") as FancyCameraArmature
		var mouse_world_position := camera.get_mouse_world_position()
		emitter_manager.emit(mouse_world_position)
	elif Input.is_action_just_pressed("action2"):
		emitter_manager.stop_emit()
	
	var top_velocity := max_velocity
	var top_velocity_reverse := max_velocity
	if weight_based_velocity_enabled:
		top_velocity = clampf(thrust_force / drag_coefficient, 0.0, max_velocity)
		top_velocity_reverse = clampf(reverse_force / drag_coefficient, 0.0, max_velocity)
	var force_deficit := (top_velocity - linear_velocity.length()) / delta * mass
	var reverse_deficit := (top_velocity_reverse - linear_velocity.length()) / delta * mass
	
	if thrust_input:
		var desired_direction := Vector3.FORWARD.rotated(Vector3.UP, rotation.y) 
		var negative_force := -(linear_velocity.normalized() - desired_direction) * thrust_force as Vector3
		var force_to_apply := (desired_direction * clampf(force_deficit, 0, thrust_force)) + negative_force
		apply_central_force(force_to_apply)
	
	if reverse_input:
		var desired_direction := Vector3.BACK.rotated(Vector3.UP, rotation.y)
		var negative_force := -(linear_velocity.normalized() - desired_direction) * reverse_force as Vector3
		var force_to_apply := (desired_direction * clampf(reverse_deficit, 0, reverse_force)) + negative_force
		apply_central_force(force_to_apply)
	
	# TODO: change this to a better stop
	var linear_stop := stop_input
	if not thrust_input and not reverse_input:
		linear_stop = true
	
	_enable_rcs_thruster_effect(rotation_input)
	if rotation_input:
		# Maybe body direct state should be retrieved only once
		var inverse_inertia :=  PhysicsServer3D.body_get_direct_state(get_rid()).inverse_inertia
		var acceleration_defficit := (max_turn_speed - absf(angular_velocity.y)) / delta as float
		apply_torque(-Vector3.UP * rotation_input * clamp(turn_acceleration, -acceleration_defficit, acceleration_defficit) / inverse_inertia)
	else:
		var inverse_inertia := PhysicsServer3D.body_get_direct_state(get_rid()).inverse_inertia
		if inverse_inertia.y != 0:
			var reverse_angular_acceleration := -angular_velocity.y / delta as float
			reverse_angular_acceleration = clamp(reverse_angular_acceleration, -turn_acceleration, turn_acceleration)
			apply_torque(Vector3.UP * reverse_angular_acceleration / inverse_inertia.y)
	
	if linear_stop:
		var negative_acceleration := -linear_velocity.normalized() * starting_linear_amount_stop
		apply_central_force(mass * negative_acceleration)
		
	if stop_input:
		var inverse_inertia = PhysicsServer3D.body_get_direct_state(get_rid()).inverse_inertia
		var reverse_angular_acceleration := -angular_velocity.y / delta as float
		reverse_angular_acceleration = clamp(reverse_angular_acceleration, -stop_angular_amount, stop_angular_amount)
		apply_torque(Vector3.UP * reverse_angular_acceleration / inverse_inertia)
	
