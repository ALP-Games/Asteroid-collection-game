@tool
class_name Handle extends RigidBody3D

enum State {
	IDLE,
	ANIMATED
}

var _current_state: State = State.IDLE

@export_range(-360, 360, 0.001, "radians_as_degrees") var starting_angle: float
@export_range(-360, 360, 0.001, "radians_as_degrees") var target_angle: float
@export var rotation_animation_duration: float = 0.5

@export var _show_target_instead_of_starting: bool = false:
	set(value):
		_show_target_instead_of_starting = value
		if is_node_ready():
			_update_handle_rotation()
@export var play_rotation_animation: bool = false:
	set(value):
		play_rotation_animation = value
		if play_rotation_animation:
			start_enablement_animation(func():play_rotation_animation=false)


@onready var handle_pivot = $Graphics/HandlePivot


# TODO: add smooth rotation to desegnated position
# add a function that can be bound to a signal to do so
func _ready():
	pass


func _process(_delta):
	if not Engine.is_editor_hint():
		return
	if _current_state != State.IDLE or play_rotation_animation:
		return
	_update_handle_rotation()


func start_enablement_animation(do_at_end: Callable = _do_nothing) -> void:
	var enablement_tween := create_tween()
	_current_state = State.ANIMATED
	_show_target_instead_of_starting = false
	enablement_tween.tween_property(handle_pivot, "rotation:x", \
		target_angle, rotation_animation_duration).\
			set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	enablement_tween.tween_callback(func():_current_state = State.IDLE)
	if do_at_end != _do_nothing:
		enablement_tween.tween_callback(do_at_end)


func _do_nothing() -> void:
	pass


func _update_handle_rotation() -> void:
	if _show_target_instead_of_starting:
		handle_pivot.rotation.x = target_angle
	else:
		handle_pivot.rotation.x = starting_angle
