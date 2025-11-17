class_name HookUI extends PanelContainer

const HOOK_COUNT_FORMAT = &"%1d/%1d"

@onready var hook_count: Label = $LabelContainer/HookCount

func set_hook_count(current: int, max_count: int) -> void:
	hook_count.text = HOOK_COUNT_FORMAT % [current, max_count]
