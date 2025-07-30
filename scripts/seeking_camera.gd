extends Camera3D

@export var target: Node3D = null

var on_process: Callable = process_nothing


func _ready() -> void:
	if target:
		on_process = seek_target


func _process(delta: float) -> void:
	on_process.call(delta)
	if Input.is_action_just_pressed("fullscreen"):
		var fs := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func seek_target(_delta: float) -> void:
	global_position = Vector3(target.global_position.x, global_position.y, target.global_position.z)


func process_nothing(_delta: float) -> void:
	pass
