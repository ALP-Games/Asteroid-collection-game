extends VBoxContainer

const VICTORY_LEVEL = preload("res://levels/game_end.tscn")

@onready var buy_button: Button = $Panel/ContentEstate/HBoxContainer/BuyButton
@onready var click_sound_player: AudioStreamPlayer = $ClickSoundPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buy_button.button_down.connect(func():click_sound_player.play())
	buy_button.pressed.connect(_finish_game, CONNECT_ONE_SHOT)


func _finish_game() -> void:
	var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
	var timer_instance := Timer.new()
	instantiated_root.add_child(timer_instance)
	timer_instance.start(0.5)
	timer_instance.timeout.connect(func():get_tree().change_scene_to_packed(VICTORY_LEVEL))
