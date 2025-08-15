class_name WarningBox extends VBoxContainer

static var shown_warinings: Array[WarningBox]

@export var warning_priority: int = 0

# TODO: make sure 2 WarningBoxes are not active at the same time

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	visible = false


func show_warning() -> void:
	# this looks like there is too much code
	if shown_warinings.size() > 0:
		if shown_warinings[0] == self:
			_show()
			return
		if warning_priority > shown_warinings[0].warning_priority:
			shown_warinings[0].hide_warning()
			shown_warinings.push_front(self)
			_show()
			return
		else:
			for warning_index in shown_warinings.size():
				if warning_index == 0: continue
				if warning_priority > shown_warinings[warning_index].warning_priority:
					shown_warinings.insert(warning_index, self)
					return
	else:
		_show()
	shown_warinings.append(self)


func _show() -> void:
	visible = true
	animation_player.play("flashing")


func hide_warning() -> void:
	if shown_warinings.size() > 0 and shown_warinings[0] == self:
		shown_warinings.remove_at(0)
		if shown_warinings.size() > 0:
			shown_warinings.front().show_warning()
	else:
		shown_warinings.erase(self)
	visible = false
	animation_player.stop()
