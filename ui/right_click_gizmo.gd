class_name RightClickGizmo extends Control

var node_to_follow: Node3D = null
var camera: Camera3D = null

@export var fade_in_time: float = 0.15

@onready var right_click_icon: TextureRect = $RightClickIcon


func _ready() -> void:
	add_to_group("right_click_gizmo")
	camera = (get_tree().get_first_node_in_group("camera") as FancyCameraArmature).camera_3d
	disable()


func enable_on(node : Node3D) -> void:
	node_to_follow = node
	right_click_icon.visible = true
	right_click_icon.modulate.a = 0
	var fade_in_tween := create_tween()
	fade_in_tween.tween_property(right_click_icon, "modulate:a", 1.0, fade_in_time)
	
	#var fade_out_tween := create_tween()
	#fade_out_tween.tween_property(title_card, "modulate:a", 0.0, fade_out_time)
	#fade_out_tween.tween_callback(func():process_functions.erase(_process_title_card_position))
	#process_functions.erase(_process_any_registered_input_pressed)
	set_process(true)


func disable() -> void:
	node_to_follow = null
	right_click_icon.visible = false
	set_process(false)


func enabled() -> bool:
	return right_click_icon.visible


func _process(delta: float) -> void:
	#if not node_to_follow:
		#return
	right_click_icon.global_position = camera.unproject_position(node_to_follow.global_position) - (right_click_icon.size / 2)
