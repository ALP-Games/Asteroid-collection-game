class_name LatchMechanism extends RigidBody3D

signal unlatched

const MIN_UPPER_DISTANCE: float = 1.0
const MIN_DETATCH_DISTANCE: float = 0.9
const MIN_PROTRUSION_DISTANCE: float = 0.1

@export var debug: bool = false
@export var attachment_node: PhysicsBody3D
@export_group("Latch Behaviour")
@export var retraction_acceleration: float = 50.0
@export var strength_exponent: float = 2.0
@export var unlatch_impulse: float = 40.0
@export var deflation_duration: float = 2.0
@export var dependant_latches: Array[LatchMechanism]
@export var share_dependence: bool = true
@export_group("Sound Effects")
@export var sound_max_volume_db: float = 0.0
@export var sound_min_volume_db: float = -40.0
@export var sound_max_pitch: float = 1.0
@export var sound_min_pitch: float = 0.9

@onready var slider_joint_3d: SliderJoint3D = $SliderJoint3D
@onready var housing_attachment: Generic6DOFJoint3D = $HousingAttachment
@onready var latch: RigidBody3D = $Latch
@onready var gas_emission_effects_side: Array[GPUParticles3D] = [$GasEmissionEffectLeft, $GasEmissionEffectRight]
@onready var gas_emission_effect_front: GPUParticles3D = $GasEmissionEffectFront
@onready var gas_sound: AudioStreamPlayer3D = $GasSound


@onready var _slider_length := slider_joint_3d.get_param(SliderJoint3D.PARAM_LINEAR_LIMIT_UPPER) -\
	slider_joint_3d.get_param(SliderJoint3D.PARAM_LINEAR_LIMIT_LOWER)
#@onready var _slider_start_pos := slider_joint_3d.position.z +\
	#slider_joint_3d.get_param(SliderJoint3D.PARAM_LINEAR_LIMIT_UPPER) - MIN_UPPER_DISTANCE
	
var latched := true

func _ready() -> void:
	#print("Slider length - ", _slider_length)
	#print("Latch position - ", latch.position.z)
	for effect in gas_emission_effects_side:
		effect.amount_ratio = 0.0
	
	gas_emission_effect_front.emitting = false
	
	gas_sound.playing = true
	gas_sound.stream_paused = true
	
	if share_dependence:
		for dependant_latch in dependant_latches:
			if dependant_latch.dependant_latches.find(self) == -1:
				dependant_latch.dependant_latches.append(self)
	
	if attachment_node:
		housing_attachment.node_b = attachment_node.get_path()

func _physics_process(_delta: float) -> void:
	# we can't use global z, we need to normalize it or something
	# or we can try relative position for now
	# it could also be calculated once
	if latched:
		_process_latch()

func _process_latch() -> void:
	var protruded_amount := 0 - latch.position.z
	#print("Latch position - ", latch.position.z)
	if ready_to_unlatch():
		var unlatch := true
		for dependant_latch in dependant_latches:
			if not dependant_latch.ready_to_unlatch():
				unlatch = false
				break
		if unlatch:
			_do_unlatch()
	
	var emission_ratio: float = clampf(protruded_amount - MIN_PROTRUSION_DISTANCE /  _slider_length - MIN_PROTRUSION_DISTANCE, 0.0, 1.0)
	for effect in gas_emission_effects_side:
		effect.amount_ratio = emission_ratio
	
	gas_sound.stream_paused = protruded_amount < MIN_PROTRUSION_DISTANCE
	gas_sound.volume_db = lerp(sound_min_volume_db, sound_max_volume_db, emission_ratio)
	gas_sound.pitch_scale = lerp(sound_min_pitch, sound_max_pitch, emission_ratio)
	
	if protruded_amount / _slider_length > MIN_PROTRUSION_DISTANCE:
		var retraction_strength := pow(retraction_acceleration * protruded_amount / _slider_length, strength_exponent)
		latch.apply_central_force(Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, latch.global_rotation.y) * latch.mass * retraction_strength)


func _do_unlatch() -> void:
	latched = false
	slider_joint_3d.queue_free()
	housing_attachment.queue_free()
	var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
	var latch_global_transform := latch.global_transform
	var housing_global_transform := global_transform
	remove_child(latch)
	instantiated_root.add_child(latch)
	latch.global_transform = latch_global_transform
	get_parent().remove_child(self)
	instantiated_root.add_child(self)
	global_transform = housing_global_transform
	
	latch.apply_central_impulse(Vector3(0.0, 0.0, -1.0).rotated(Vector3.UP, latch.global_rotation.y) * latch.mass * unlatch_impulse)
	apply_central_impulse(Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, latch.global_rotation.y) * mass * unlatch_impulse)
	#gas_emission_effect.emitting = false
	
	for effect in gas_emission_effects_side:
		effect.amount_ratio = 0.0
		effect.emitting = false
	
	gas_emission_effect_front.amount_ratio = 1.0
	gas_emission_effect_front.emitting = true
	
	var deflation_tween := create_tween()
	deflation_tween.tween_property(self, "gas_emission_effect_front:amount_ratio", 0.0, deflation_duration).\
		set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	deflation_tween.tween_callback(func():gas_emission_effect_front.emitting = false)
	
	gas_sound.volume_db = sound_max_volume_db
	var deflation_volume_tween := create_tween()
	deflation_volume_tween.tween_property(self, "gas_sound:volume_db", sound_min_volume_db, deflation_duration).\
		set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	deflation_volume_tween.tween_callback(func():gas_sound.playing = false)
	
	var deflation_pitch_tween := create_tween()
	deflation_pitch_tween.tween_property(self, "gas_sound:pitch_scale", sound_min_pitch, deflation_duration).\
		set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unlatched.emit()


func ready_to_unlatch() -> bool:
	var protruded_amount := 0 - latch.position.z
	if debug:
		print("rotruded amount - ", protruded_amount, "; slider length - ", _slider_length, "; ratio - ", protruded_amount / _slider_length)
	return protruded_amount / _slider_length >= MIN_DETATCH_DISTANCE
