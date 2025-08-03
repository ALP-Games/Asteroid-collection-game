class_name PlayerShip extends RigidBody3D

@export var max_velocity: float = 30

@export var starting_acceleration: float = 20
@export var starting_reverse_acceleration: float = 10
@export var turn_acceleration: float = 10.0
@export var max_turn_speed: float = 4.0

@onready var starting_mass: float = mass
@onready var thrust_force: float = starting_acceleration * starting_mass
@onready var reverse_force: float = starting_reverse_acceleration * starting_mass

@export var stabilization_warning_multiple: float = 2.0
@export var destabilized_time: float = 0.25
var destabilized_elapsed := 0.0

@export var stop_linear_amount: float = 20
@export var stop_angular_amount: float = 10

@export var max_graphics_tilt: float = 45.0

@onready var graphics: Node3D = $Graphics
@onready var emitter_manager: EmitterManager = $EmitterManager

const MAX_JET_VELOCITY := 25.0
const JET_MIN_SCALE := 0.01
const JET_MAX_SCALE := 1.0

@onready var jet_beam: Node3D = $Graphics/JetBeam
@onready var jet_beam_2: Node3D = $Graphics/JetBeam2


var in_shop_range := false


func _ready() -> void:
	GameManager.upgrade_data.upgrade_incremented.connect(_thrusters_upgraded)


func _thrusters_upgraded(upgrade_id: UpgradeData.UpgradeType, upgrade_level: int) -> void:
	if upgrade_id != UpgradeData.UpgradeType.ENGINE_POWER:
		return
	match upgrade_level:
		0:
			thrust_force = starting_mass * starting_acceleration
			reverse_force = starting_mass * starting_reverse_acceleration
		1:
			thrust_force = starting_mass * 25.0
			reverse_force = starting_mass * 10.0
		2:
			thrust_force = starting_mass * 30.0
			reverse_force = starting_mass * 15.0


func _process(delta: float) -> void:
	var turn_ratio := angular_velocity.y / max_turn_speed
	graphics.rotation.z = deg_to_rad(max_graphics_tilt) * turn_ratio
	
	#var velocity_ration := linear_velocity.length() / MAX_JET_VELOCITY
	var jet_scale := remap(linear_velocity.length(), 0, MAX_JET_VELOCITY, JET_MIN_SCALE, JET_MAX_SCALE)
	jet_beam.scale = Vector3(jet_scale, jet_scale, jet_scale)
	jet_beam_2.scale = Vector3(jet_scale, jet_scale, jet_scale)


func _physics_process(delta: float) -> void:
	if angular_velocity.y >= max_turn_speed * stabilization_warning_multiple:
		destabilized_elapsed += delta
		if destabilized_elapsed >= destabilized_time:
			(get_tree().get_first_node_in_group("stabilization_warinig") as Control).visible = true
	else:
		if destabilized_elapsed >= destabilized_time:
			(get_tree().get_first_node_in_group("stabilization_warinig") as Control).visible = false
		destabilized_elapsed = 0.0
	
	var shop_screen: Control = get_tree().get_first_node_in_group("shop_screen")
	
	if (shop_screen.visible or in_shop_range) and Input.is_action_just_pressed("open_shop"):
		shop_screen.visible = !shop_screen.visible
	
	if shop_screen.visible:
		return
	
	var thrust_input := Input.is_action_pressed("thrust")
	var reverse_input := Input.is_action_pressed("reverse")
	var stop_input := Input.is_action_pressed("stop")
	var rotation_input := Input.get_axis("rot_left", "rot_right")
	
	if Input.is_action_just_pressed("action"):
		var camera := get_tree().get_first_node_in_group("camera") as FancyCamera3D
		var mouse_world_position := camera.get_mouse_world_position()
		emitter_manager.emit(mouse_world_position)
	elif Input.is_action_just_pressed("action2"):
		emitter_manager.stop_emit()
	
	#var camera := get_tree().get_first_node_in_group("camera") as FancyCamera3D
	#var mouse_world_position := camera.get_mouse_world_position()
	#rope_prototype.look_at(mouse_world_position)
	
	if thrust_input:
		var force_deficit := (max_velocity - linear_velocity.length()) / delta * mass
		
		var desired_direction := Vector3.FORWARD.rotated(Vector3.UP, rotation.y) 
		var negative_force := -(linear_velocity.normalized() - desired_direction) * thrust_force as Vector3
		var force_to_apply := (desired_direction * clampf(force_deficit, 0, thrust_force)) + negative_force
		apply_central_force(force_to_apply)
	
	if reverse_input:
		var desired_direction := Vector3.BACK.rotated(Vector3.UP, rotation.y)
		var negative_force := -(linear_velocity.normalized() - desired_direction) * reverse_force as Vector3
		var force_to_apply := (desired_direction * reverse_force) + negative_force
		apply_central_force(force_to_apply)
	
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
	
	if stop_input:
		var negative_acceleration := -linear_velocity.normalized() * stop_linear_amount
		apply_central_force(mass * negative_acceleration)
		
		var inverse_inertia = PhysicsServer3D.body_get_direct_state(get_rid()).inverse_inertia
		var reverse_angular_acceleration := -angular_velocity.y / delta as float
		reverse_angular_acceleration = clamp(reverse_angular_acceleration, -stop_angular_amount, stop_angular_amount)
		apply_torque(Vector3.UP * reverse_angular_acceleration / inverse_inertia)
	
