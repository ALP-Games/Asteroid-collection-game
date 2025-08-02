class_name FancyCamera3D extends Camera3D

@export var target: Node3D = null

var on_process: Callable = process_nothing
var ground_plane := Plane(Vector3.UP, 0.0)


func _ready() -> void:
	add_to_group("camera")
	if target:
		on_process = seek_target


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("fullscreen"):
		var fs := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if Input.is_action_just_pressed("reload"):
		GameManager.initialize()
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	on_process.call(delta)


func get_mouse_world_position() -> Vector3:
	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin := project_ray_origin(mouse_position)
	var ray_direction := project_ray_normal(mouse_position)
	var ray_length := 1000
	var ray_end := ray_origin + ray_direction * ray_length
	
	var intersection := ground_plane.intersects_ray(ray_origin, ray_end) as Vector3
	#print("Mouse world position: ", intersection)
	if intersection == null:
		return Vector3.ZERO
	return intersection



func seek_target(_delta: float) -> void:
	global_position = Vector3(target.global_position.x, global_position.y, target.global_position.z)


func process_nothing(_delta: float) -> void:
	pass
