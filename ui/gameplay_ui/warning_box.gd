class_name WarningBox extends VBoxContainer

# TODO: make sure 2 WarningBoxes are not active at the same time

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	visible = false


func show_warning() -> void:
	visible = true
	animation_player.play("flashing")


func hide_warning() -> void:
	visible = false
	animation_player.stop()
