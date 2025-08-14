class_name PauseMenu extends Control

const CLICK_SOUND_PLAYER = preload("res://ui/click_sound_player.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _play_click_sound() -> void:
	var click_sound_instance = CLICK_SOUND_PLAYER.instantiate() as AudioStreamPlayer
	get_tree().root.add_child(click_sound_instance)
	click_sound_instance.play()
	click_sound_instance.finished.connect(func():click_sound_instance.queue_free(), CONNECT_ONE_SHOT)


func _on_button_resume_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_button_restart_pressed() -> void:
	GameManager.reload()


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_button_resume_button_down() -> void:
	_play_click_sound()


func _on_button_restart_button_down() -> void:
	_play_click_sound()


func _on_button_quit_button_down() -> void:
	_play_click_sound()
