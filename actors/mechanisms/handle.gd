@tool
class_name Handle extends RigidBody3D

const HANDLE_META := "handle_array"

enum State {
	IDLE,
	ANIMATED
}

var _current_state: State = State.IDLE

@export var attached_body: PhysicsBody3D
@export_range(-360, 360, 0.001, "radians_as_degrees") var starting_angle: float
@export_range(-360, 360, 0.001, "radians_as_degrees") var target_angle: float
@export var rotation_animation_duration: float = 0.5
@export var duration_randomization: float = 0.1
@export var tween_transition: Tween.TransitionType = Tween.TRANS_ELASTIC

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
			#start_enablement_animation()

#@export_group("Collisions")
@onready var collisions: Array[CollisionShape3D] = [$HandleCollision, $HandleCollision2, $HandleCollision3]


@onready var handle_pivot := $Graphics/HandlePivot
@onready var graphics: FollowNodes = $Graphics
@onready var attachment_joints: Array[Generic6DOFJoint3D] = [$AttachmentJoint, $AttachmentJoint2,
	$AttachmentJoint3, $AttachmentJoint4]


func _enter_tree() -> void:
	if not Engine.is_editor_hint() and attached_body:
		var handle_array: Array = attached_body.get_meta(HANDLE_META, [])
		handle_array.append(self)
		attached_body.set_meta(HANDLE_META, handle_array)
		#if attached_body.has_meta(HANDLE_META):
			#attached_body.get_meta(HANDLE_META)
		#else:
			#attached_body.set_meta(HANDLE_META, [self])


# TODO: add smooth rotation to desegnated position
# add a function that can be bound to a signal to do so
func _ready():
	_update_handle_rotation()
	graphics.refresh()
	if attached_body:
		for attachemnt in attachment_joints:
			attachemnt.node_b = attached_body.get_path()
	if not Engine.is_editor_hint():
		_disabe_collisions(true)

func _process(_delta):
	if not Engine.is_editor_hint():
		return
	if _current_state != State.IDLE or play_rotation_animation:
		return
	_update_handle_rotation()


func _disabe_collisions(disable: bool) -> void:
		for collision_obj in collisions:
			collision_obj.disabled = disable


func start_enablement_animation(do_at_end: Callable = _do_nothing) -> void:
	graphics.update_follow_nodes = true
	var enablement_tween := create_tween()
	_current_state = State.ANIMATED
	_show_target_instead_of_starting = false
	enablement_tween.tween_property(handle_pivot, "rotation:x", \
		target_angle, randf_range(-duration_randomization, duration_randomization) + rotation_animation_duration).\
			set_trans(tween_transition).set_ease(Tween.EASE_OUT)
	enablement_tween.tween_callback(
		func():
			_current_state = State.IDLE
			_disabe_collisions(false)
			graphics.update_follow_nodes = false)
	if do_at_end != _do_nothing:
		enablement_tween.tween_callback(do_at_end)


func _do_nothing() -> void:
	pass


func get_total_mass() -> float:
	var total_mass := mass
	if attached_body and attached_body is RigidBody3D: 
		total_mass += attached_body.mass
	return total_mass


func _update_handle_rotation() -> void:
	if _show_target_instead_of_starting:
		handle_pivot.rotation.x = target_angle
	else:
		handle_pivot.rotation.x = starting_angle
