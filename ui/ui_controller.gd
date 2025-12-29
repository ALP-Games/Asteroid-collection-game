class_name UIController extends Control

@onready var pause_menu: Control = $PauseMenu


func _ready() -> void:
	pause_menu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if not get_tree().paused:
			pause_menu.visible = true
			get_tree().paused = true
			if GameManager.get_state() == Game.State.GAMEPLAY:
				GameManager._save_manager.sync_save()
		else:
			pause_menu.visible = false
			get_tree().paused = false
