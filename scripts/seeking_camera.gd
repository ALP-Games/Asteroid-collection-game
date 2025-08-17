class_name FancyCameraArmature extends Node3D

@export var target: Node3D = null

@export_group("Speed Zoom Control")
@export var max_speed_before_zoom: float = 20.0
@export var max_zoom_speed: float = 100.0
@export var max_zoom_multiplier: float = 5.0
@export var y_interp_speed := 10.0

@export_group("First Linear Zoom")
@export var first_linear_zoom_time: float = 2.0

@export_group("Mouse Tracking")
@export var track_speed := 1.0
@export var tracking_max_distance := 3.0

@onready var camera_3d: Camera3D = $Camera3D

@onready var y_interp_speed_current := y_interp_speed

@onready var default_height: float = global_position.y

var physics_process_funcs: Array[Callable]

var previous_pos: Vector3
var current_y_offset := 0.0
var current_xz_offset := Vector2.ZERO


func _ready() -> void:
	add_to_group("camera")
	if target:
		physics_process_funcs.append(seek_target)
		#physics_process_funcs.append(lerp_camera_offset)
	if GameManager.first_start:
		camera_3d.position.z = -default_height
		current_y_offset = default_height
		physics_process_funcs.append(linear_camera_pan)
	else:
		if target:
			physics_process_funcs.append(lerp_camera_offset)
	physics_process_funcs.append(lerp_height)
	#set_physics_process(target != null)
	
	#if GameManager.first_start:
		#y_interp_speed_current = 0.0
	#if target:
		#on_process = seek_target


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("fullscreen"):
		var fs := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	#if Input.is_action_just_pressed("reload"):
		#GameManager.reload()


func _physics_process(delta: float) -> void:
	for callable in physics_process_funcs:
		callable.call(delta)
	#seek_target(delta)
	#lerp_height(delta)


func get_mouse_world_position() -> Vector3:
	var mouse_position := get_viewport().get_mouse_position()
	return camera_3d.project_position(mouse_position, position.y)


func seek_target(_delta: float) -> void:
	global_position = Vector3(target.global_position.x, global_position.y, target.global_position.z)


func lerp_height(delta: float) -> void:
	var current_pos := Vector3(previous_pos.x, 0.0, previous_pos.z)
	previous_pos = Vector3(global_position.x, 0.0, global_position.z)
	var current_speed := (previous_pos - current_pos).length() / (1.0 / Engine.physics_ticks_per_second)
	
	var weight: float = clamp((current_speed - max_speed_before_zoom) / \
											(max_zoom_speed - max_speed_before_zoom), 0.0, 1.0)
	var target_y = lerp(default_height, default_height * max_zoom_multiplier, weight)
	current_y_offset = lerp(current_y_offset, target_y, delta * y_interp_speed_current)
	global_position.y = current_y_offset


func linear_camera_pan(delta: float) -> void:
	var progress := (default_height + camera_3d.position.z) / default_height
	var change_per_tick := delta / first_linear_zoom_time
	camera_3d.position.z = lerp(-default_height, 0.0, progress + change_per_tick)
	
	if camera_3d.position.z >= 0.0:
		camera_3d.position.z = 0.0
		#global_position.y = default_height
		#current_y_offset = global_position.y
		#physics_process_funcs[physics_process_funcs.find(linear_camera_pan)] = lerp_height
		physics_process_funcs.erase(linear_camera_pan)
		if target:
			physics_process_funcs.append(lerp_camera_offset)


func lerp_camera_offset(delta: float) -> void:
	var middle_point := (target.global_position + get_mouse_world_position()) / 2
	var middle_point_offset := middle_point - global_position
	var middle_point_2d := Vector2(middle_point_offset.x, middle_point_offset.z)
	middle_point_2d = middle_point_2d.limit_length(tracking_max_distance)
	current_xz_offset = lerp(current_xz_offset, middle_point_2d, delta * track_speed)
	camera_3d.position = Vector3(current_xz_offset.x, -current_xz_offset.y, camera_3d.position.z)
