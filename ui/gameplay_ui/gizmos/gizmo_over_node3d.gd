class_name GizmoOverNode3D extends IGizmo

@export var fade_in_time: float = 0.15
@export var fade_out_time: float = 0.1

enum State
{
	ENABLED,
	DISABLED,
	ENABLING,
	DISABLING
}

var node_to_follow: Node3D = null
var camera: Camera3D = null
var state: State


func _ready() -> void:
	camera = (get_tree().get_first_node_in_group("camera") as FancyCameraArmature).camera_3d
	visible = false
	modulate.a = 0
	set_process(false)
	state = State.DISABLED


func _process(_delta: float) -> void:
	var position_to_follow := node_to_follow.get_global_transform_interpolated().origin
	global_position = camera.unproject_position(position_to_follow)


func enable() -> void:
	if state == State.ENABLED or state == State.ENABLING:
		return
	state = State.ENABLING
	visible = true
	var fade_in_left := (1.0 - modulate.a) * fade_in_time
	var fade_in_tween := create_tween()
	fade_in_tween.tween_property(self, "modulate:a", 1.0, fade_in_left)
	fade_in_tween.tween_callback(func():
		if state == State.ENABLING:
			finished_enabling.emit()
			state = State.ENABLED)
	set_process(true)


func disable() -> void:
	if state == State.DISABLED or state == State.DISABLING:
		return
	state = State.DISABLING
	var fade_out_left := modulate.a * fade_out_time
	var fade_out_tween := create_tween()
	fade_out_tween.tween_property(self, "modulate:a", 0.0, fade_out_left)
	fade_out_tween.tween_callback(func():
		if state == State.DISABLING:
			set_process(false)
			visible = false
			state = State.DISABLED
			finished_disabling.emit())

# is this one necesary?
func is_enabled() -> bool:
	return state == State.ENABLED
