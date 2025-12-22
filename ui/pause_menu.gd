class_name PauseMenu extends Control

const CLICK_SOUND_PLAYER = preload("res://ui/click_sound_player.tscn")

@export var confirmation_window: ConfirmationWindow

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	confirmation_window.visible = false


func _play_click_sound() -> void:
	#var click_sound_instance = CLICK_SOUND_PLAYER.instantiate() as AudioStreamPlayer
	#get_tree().root.add_child(click_sound_instance)
	#click_sound_instance.play()
	#click_sound_instance.finished.connect(func():click_sound_instance.queue_free(), CONNECT_ONE_SHOT)
	GameManager.play_click_sound()


func _on_button_resume_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_button_reload_pressed() -> void:
	GameManager.reload()


func _on_button_reset_save_pressed() -> void:
	confirmation_window.set_confirmation("Are you sure you want to reset your save?\nAll your progress will be wiped out!",
		func() -> void:
		GameManager.reset_save()
		GameManager.reload()
		)


func _on_button_quit_pressed() -> void:
	get_tree().quit()
