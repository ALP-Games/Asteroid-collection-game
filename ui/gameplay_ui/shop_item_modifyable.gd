class_name ShopItemModifyable extends ShopItemUI

const COUNT_FORMAT := &"%1d/%1d"

@onready var text_count: Label = $VBoxContainer/NameAndIcon/FlavorEstate/PanelAdjustable/TextContainer/TextCount
@onready var button_add: Button = $VBoxContainer/NameAndIcon/FlavorEstate/PanelAdjustable/ButtonAdd
@onready var button_remove: Button = $VBoxContainer/NameAndIcon/FlavorEstate/PanelAdjustable/ButtonRemove


#var upgrade_cur_max: Array[int]


func _ready() -> void:
	super()
	var upgrade_data := GameManager.upgrade_data
	upgrade_data.upgrade_incremented.connect(_on_upgrade_incremented)
	_check_upgrade_numbers()
	
	button_add.pressed.connect(_change_upgrade_level.bind(1))
	button_remove.pressed.connect(_change_upgrade_level.bind(-1))
	
	button_add.button_down.connect(func():click_sound_player.play())
	button_remove.button_down.connect(func():click_sound_player.play())


func _on_upgrade_incremented(_upgrade_id: UpgradeData.UpgradeType, _level: int) -> void:
	_check_upgrade_numbers()


func _check_upgrade_numbers() -> void:
	var upgrade_cur_max := GameManager.upgrade_data.get_upgrade_cur_max(upgrade_id)
	button_add.disabled = upgrade_cur_max[0] == upgrade_cur_max[1]
	button_remove.disabled = upgrade_cur_max[0] == 0
	text_count.text = COUNT_FORMAT % upgrade_cur_max


func _change_upgrade_level(change: int) -> void:
	GameManager.upgrade_data.change_upgrade_level(upgrade_id, change)
