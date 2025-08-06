class_name GameplayUI extends Control

@onready var gameplay_ui: MainUI = $GameplayUI
@onready var pause_menu: Control = $PauseMenu


func _ready() -> void:
	pause_menu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if not get_tree().paused:
			pause_menu.visible = true
			get_tree().paused = true
		else:
			pause_menu.visible = false
			get_tree().paused = false
