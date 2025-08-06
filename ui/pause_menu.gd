class_name PauseMenu extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_button_resume_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_button_restart_pressed() -> void:
	GameManager.reload()


func _on_button_quit_pressed() -> void:
	get_tree().quit()
