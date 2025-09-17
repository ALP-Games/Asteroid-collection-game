class_name UpgradeDataRes extends Resource

@export var icon: Texture2D
@export var upgrade_type: UpgradeData.UpgradeType
@export var data: Array[UpgradeEntry]
@export var variables: Array[IUpgradeVariables]
@export var upgrade_scene: PackedScene = preload("res://ui/gameplay_ui/shop_item_ui.tscn")

@export_group("Defaults")
@export var upgrade_name: StringName
@export var buy_text: StringName = &"Buy"

func get_data(index: int) -> UpgradeEntry:
	assert(data.size() > 0)
	var entry: UpgradeEntry
	if index >= data.size():
		entry = data.back()
	elif index < 0:
		entry = data.front()
	else:
		entry = data[index]
	_validate_entry(entry)
	return entry


func _validate_entry(entry: UpgradeEntry) -> void:
	if entry.buy_text.is_empty():
		entry.buy_text = buy_text
	if entry.upgrade_name.is_empty():
		entry.upgrade_name = upgrade_name
