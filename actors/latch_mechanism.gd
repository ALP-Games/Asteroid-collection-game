class_name LatchMechanism extends Node3D

const MIN_UPPER_DISTANCE: float = 1.0
const MIN_DETATCH_DISTANCE: float = 0.9

@export var retraction_acceleration: float = 50.0
@export var strength_exponent: float = 2.0

@onready var slider_joint_3d: SliderJoint3D = $SliderJoint3D
@onready var latch: RigidBody3D = $Latch

@onready var _slider_length := slider_joint_3d.get_param(SliderJoint3D.PARAM_LINEAR_LIMIT_UPPER) -\
	slider_joint_3d.get_param(SliderJoint3D.PARAM_LINEAR_LIMIT_LOWER)
#@onready var _slider_start_pos := slider_joint_3d.position.z +\
	#slider_joint_3d.get_param(SliderJoint3D.PARAM_LINEAR_LIMIT_UPPER) - MIN_UPPER_DISTANCE
	
var latched := true

func _ready() -> void:
	print("Slider length - ", _slider_length)
	print("Latch position - ", latch.position.z)

func _physics_process(delta: float) -> void:
	# we can't use global z, we need to normalize it or something
	# or we can try relative position for now
	# it could also be calculated once
	if latched:
		_process_latch()

func _process_latch() -> void:
	var protruded_amount := 0 - latch.position.z
	#print("Latch position - ", latch.position.z)
	if protruded_amount / _slider_length >= MIN_DETATCH_DISTANCE:
		latched = false
		slider_joint_3d.queue_free()
		
	#print("Protruded amount - ", protruded_amount)
	if protruded_amount > 0:
		var retraction_strength := pow(retraction_acceleration * protruded_amount / _slider_length, strength_exponent)
		latch.apply_central_force(Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, latch.global_rotation.y) * latch.mass * retraction_strength)
	#print("Latch velocity - ", latch.linear_velocity)
