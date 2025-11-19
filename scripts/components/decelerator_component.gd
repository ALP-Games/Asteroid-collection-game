## TODO: Add short component description
class_name DeceleratorComponent
extends Component

@onready var parent_body: RigidBody3D = get_parent()

@export var deceleration_amount: float = 10.0
@export var deceleration_sounds: Array[AudioStreamPlayer3D]
@export var deceleration_effects: Array[GPUParticles3D]

var decelerate := true


static func core() -> ComponentCore:
	return ComponentCore.new(DeceleratorComponent)


#decelration enabled/disabled
# when decelerated stops the graphics, but will continue to decelerate again

func _physics_process(delta: float) -> void:
	var deceleration_deficit: float = min(parent_body.linear_velocity.length() / delta, deceleration_amount)
	var negative_acceleration := -parent_body.linear_velocity.normalized() * deceleration_deficit
	#print("Negative acceleration - ", negative_acceleration)
	var enable_effects := decelerate and not is_zero_approx(parent_body.linear_velocity.length())
	_enable_graphics(enable_effects)
	_enable_sound(enable_effects)
	if not decelerate:
		return
	parent_body.apply_central_force(parent_body.mass * negative_acceleration)


func _enable_graphics(enable: bool) -> void:
	for deceleration_effect in deceleration_effects:
		deceleration_effect.emitting = enable


func _enable_sound(enable: bool) -> void:
	if enable:
		for deceleration_sound in deceleration_sounds:
			if not deceleration_sound.playing and not deceleration_sound.stream_paused:
				deceleration_sound.play()
			deceleration_sound.stream_paused = false
	else:
		for deceleration_sound in deceleration_sounds:
			deceleration_sound.stream_paused = true
