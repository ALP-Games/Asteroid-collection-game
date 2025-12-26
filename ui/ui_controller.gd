class_name GameplayUI extends Control

@export_group("Title Card")
@export var title_card_position_node: Node3D
@export var delay_before_input_read: float = 2.0
@export var fade_out_time: float = 1.0

@onready var gameplay_ui: MainUI = $GameplayUI
@onready var pause_menu: Control = $PauseMenu
@onready var title_card: TextureRect = $TitleCard

var process_functions: Array[Callable]


func _ready() -> void:
	pause_menu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	if GameManager.save_data.fresh_load:
		assert(title_card_position_node != null)
		title_card.visible = true
		process_functions.append(_process_title_card_position)
		get_tree().create_timer(delay_before_input_read).timeout.\
			connect(func():process_functions.append(_process_any_registered_input_pressed))


func _process_title_card_position(_delta: float) -> void:
	if title_card_position_node:
		title_card.global_position = (get_tree().get_first_node_in_group("camera") as FancyCameraArmature).\
			camera_3d.unproject_position(title_card_position_node.global_position) - (title_card.size / 2)


func _process_any_registered_input_pressed(_delta: float) -> void:
	for action_name in InputMap.get_actions():
		if action_name.begins_with("ui_"):
			continue
		if Input.is_action_pressed(action_name):
			# fade out the title card
			var fade_out_tween := create_tween()
			fade_out_tween.tween_property(title_card, "modulate:a", 0.0, fade_out_time)
			fade_out_tween.tween_callback(func():process_functions.erase(_process_title_card_position))
			process_functions.erase(_process_any_registered_input_pressed)
			pass


func _process(delta: float) -> void:
	for callable in process_functions:
		callable.call(delta)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if not get_tree().paused:
			pause_menu.visible = true
			get_tree().paused = true
			GameManager._save_manager.sync_save()
		else:
			pause_menu.visible = false
			get_tree().paused = false
