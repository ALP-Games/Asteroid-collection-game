class_name FancyCamera3D extends Camera3D

@export var target: Node3D = null

@export_group("Speed Zoom Control")
@export var max_speed_before_zoom: float = 20.0
@export var max_zoom_speed: float = 100.0
@export var max_zoom_multiplier: float = 5.0
@export var y_interp_speed := 10.0

@export_group("First Linear Zoom")
@export var first_linear_zoom_time: float = 2.0

@onready var y_interp_speed_current := y_interp_speed

@onready var default_height: float = global_position.y

var physics_process_funcs: Array[Callable]

var previous_pos: Vector3
var current_y_offset := 0.0


func _ready() -> void:
	add_to_group("camera")
	if target:
		physics_process_funcs.append(seek_target)
	if GameManager.first_start:
		global_position.y = 0.0
		physics_process_funcs.append(linear_height_change)
	else:
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
	return project_position(mouse_position, position.y)


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


func linear_height_change(delta: float) -> void:
	var progress := (global_position.y / (default_height - 0))
	var change_per_tick := delta / first_linear_zoom_time
	global_position.y = lerp(0.0, default_height, progress + change_per_tick)
	
	if global_position.y >= default_height:
		#global_position.y = default_height
		current_y_offset = global_position.y
		physics_process_funcs[physics_process_funcs.find(linear_height_change)] = lerp_height
