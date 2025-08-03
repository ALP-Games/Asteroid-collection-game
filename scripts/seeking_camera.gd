class_name FancyCamera3D extends Camera3D

@export var target: Node3D = null

@export var max_speed_before_zoom: float = 20

@onready var default_height: float = global_position.y

var on_process: Callable = process_nothing
var ground_plane := Plane(Vector3.UP, 0.0)

var previous_pos: Vector3
var current_y_offset := 0.0


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

@export var y_interp_speed := 10.0

func seek_target(_delta: float) -> void:
	global_position = Vector3(target.global_position.x, global_position.y, target.global_position.z)
	
	
	var current_pos := Vector3(previous_pos.x, 0.0, previous_pos.z)
	previous_pos = Vector3(global_position.x, 0.0, global_position.z)
	var current_speed := (previous_pos - current_pos).length() / (1.0 / Engine.physics_ticks_per_second)
	
	var weight: float = clamp((current_speed - max_speed_before_zoom) / \
											(100.0 - max_speed_before_zoom), 0.0, 1.0)
	var target_y = lerp(default_height, default_height*2, weight)
	current_y_offset = lerp(current_y_offset, target_y, _delta * y_interp_speed)
	global_position.y = current_y_offset


func process_nothing(_delta: float) -> void:
	pass
