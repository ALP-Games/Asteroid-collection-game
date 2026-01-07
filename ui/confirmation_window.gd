class_name ConfirmationWindow extends Control

@export var confirmation_label: Label

var confirm_action: Callable = _do_nothing


func set_confirmation(text: String, action: Callable) -> void:
	confirmation_label.text = text
	confirm_action = action
	visible = true


func _on_confirm_pressed() -> void:
	visible = false
	confirm_action.call()
	confirm_action = _do_nothing


func _on_cancel_pressed() -> void:
	visible = false
	confirm_action = _do_nothing


func _do_nothing() -> void:
	pass
