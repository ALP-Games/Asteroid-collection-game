class_name PauseMenu extends Control

const CLICK_SOUND_PLAYER = preload("res://ui/click_sound_player.tscn")

@onready var gameplay_elements := [$HBoxContainer/VBoxContainer/ButtonReload, 
						$HBoxContainer/VBoxContainer/ButtonResetSave,
						$HBoxContainer/VBoxContainer/TextureRect]

@onready var victory_level_elements := [$HBoxContainer/VBoxContainer/ButtonBackToGameplay]

@export var confirmation_window: ConfirmationWindow

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	confirmation_window.visible = false
	_refresh_state()
	GameManager.game_state_changed.connect(_refresh_state)


func _refresh_state() -> void:
	match GameManager.get_state():
		Game.State.GAMEPLAY:
			_enable_elements(victory_level_elements, false)
			_enable_elements(gameplay_elements, true)
		Game.State.VICTORY_SCREEN:
			_enable_elements(gameplay_elements, false)
			_enable_elements(victory_level_elements, true)


func _enable_elements(elements: Array, enable: bool) -> void:
	for element: Control in elements:
		element.visible = enable


func _play_click_sound() -> void:
	GameManager.play_click_sound()


func _on_button_resume_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_button_reload_pressed() -> void:
	GameManager.reload()
	visible = false


func _on_button_reset_save_pressed() -> void:
	confirmation_window.set_confirmation("Are you sure you want to reset your save?\nAll your progress will be wiped out!",
		func() -> void:
		GameManager.reset_save()
		GameManager.reload()
		visible = false
		)


func _on_button_back_to_gameplay_pressed() -> void:
	GameManager.load_gameplay()
	visible = false
	get_tree().paused = false


func _on_button_quit_pressed() -> void:
	GameManager.quit_game()
