class_name UpgradeDataRes extends Resource

@export var icon: Texture2D
@export var upgrade_type: UpgradeData.UpgradeType
@export var data: Array[UpgradeEntry]

@export_group("Defaults")
@export var upgrade_name: StringName
@export var buy_text: StringName = &"Buy"
