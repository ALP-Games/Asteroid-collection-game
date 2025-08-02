extends RigidBody3D

@export var max_velocity: float = 10

@export var thrust_acceleration: float = 20
@export var reverse_acceleration: float = 10
@export var turn_acceleration: float = 10.0
@export var max_turn_speed: float = 4.0

@export var stop_linear_amount: float = 20
@export var stop_angular_amount: float = 10

@onready var rope_emitter: RopeEmitter = $HookRope
#@onready var rope_prototype: Node3D = $AnchorRope


#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.is_pressed():
		#var mouse_button_event := event as InputEventMouseButton
		


func _physics_process(delta: float) -> void:
	var thrust_input := Input.is_action_pressed("thrust")
	var reverse_input := Input.is_action_pressed("reverse")
	var stop_input := Input.is_action_pressed("stop")
	var rotation_input := Input.get_axis("rot_left", "rot_right")
	
	if Input.is_action_just_pressed("action"):
		var camera := get_tree().get_first_node_in_group("camera") as FancyCamera3D
		var mouse_world_position := camera.get_mouse_world_position()
		rope_emitter.shoot_rope(mouse_world_position)
	
	#var camera := get_tree().get_first_node_in_group("camera") as FancyCamera3D
	#var mouse_world_position := camera.get_mouse_world_position()
	#rope_prototype.look_at(mouse_world_position)
	
	if thrust_input:
		var acceleration_deficit := (max_velocity - linear_velocity.length()) / delta
		
		var desired_direction := Vector3.FORWARD.rotated(Vector3.UP, rotation.y) 
		var negative_acceleration := -(linear_velocity.normalized() - desired_direction) * thrust_acceleration as Vector3
		var force_to_apply := (desired_direction * clampf(acceleration_deficit, 0, thrust_acceleration) \
			* mass) + (negative_acceleration * mass)
		apply_central_force(force_to_apply)
	
	if reverse_input:
		var desired_direction := Vector3.BACK.rotated(Vector3.UP, rotation.y)
		var negative_acceleration := -(linear_velocity.normalized() - desired_direction) * reverse_acceleration as Vector3
		var force_to_apply := (desired_direction * reverse_acceleration * mass) + (negative_acceleration * mass)
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
	
