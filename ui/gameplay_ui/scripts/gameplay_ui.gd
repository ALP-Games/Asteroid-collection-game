class_name GameplayUI extends Control

const MONEY_SOUND_PLAYER = preload("uid://t52u73lvsdf1")

@onready var credits_amount: Label = $LayoutsContainer/HBoxContainer/CreditsAmountControl/Amount
@onready var _original_modulate := credits_amount.modulate
@onready var title_card: TextureRect = $TitleCard

@export_group("Title Card")
@export var title_card_position_node: Node3D
@export var delay_before_input_read: float = 2.0
@export var fade_out_time: float = 1.0
@export_group("Addition effect")
@export var credits_pop_scale := 1.2
@export var credits_pop_time := 0.2
@export_group("Subtraction effect")
@export var subtraction_flash := Color.RED
@export var subtraction_effect_time := 0.2

var process_functions: Array[Callable]
var _previous_credits_amount := 0

func _ready() -> void:
	_previous_credits_amount = GameManager.credist_amount
	GameManager.credits_amount_changed.connect(on_credit_amount_changed)
	on_credit_amount_changed(GameManager.credist_amount)
	if GameManager.save_data.fresh_load:
		assert(title_card_position_node != null)
		title_card.visible = true
		process_functions.append(_process_title_card_position)
		get_tree().create_timer(delay_before_input_read).timeout.\
			connect(func():process_functions.append(_process_any_registered_input_pressed))


func _process_title_card_position(_delta: float) -> void:
	if title_card_position_node:
		title_card.global_position = (get_tree().get_first_node_in_group("camera") as FancyCameraArmature).\
			camera_3d.unproject_position(title_card_position_node.global_position) - (title_card.size / 2)


func _process_any_registered_input_pressed(_delta: float) -> void:
	for action_name in InputMap.get_actions():
		if action_name.begins_with("ui_"):
			continue
		if Input.is_action_pressed(action_name):
			# fade out the title card
			var fade_out_tween := create_tween()
			fade_out_tween.tween_property(title_card, "modulate:a", 0.0, fade_out_time)
			fade_out_tween.tween_callback(func():process_functions.erase(_process_title_card_position))
			process_functions.erase(_process_any_registered_input_pressed)


func _process(delta: float) -> void:
	for callable in process_functions:
		callable.call(delta)


func on_credit_amount_changed(new_amount: int) -> void:
	credits_amount.text = str(new_amount)
	if _previous_credits_amount < new_amount:
		var pop_tween := create_tween()
		pop_tween.tween_property(credits_amount, "scale", Vector2.ONE * credits_pop_scale, credits_pop_time / 2)
		pop_tween.tween_property(credits_amount, "scale", Vector2.ONE, credits_pop_time / 2)
		var sound_player: AudioStreamPlayer = MONEY_SOUND_PLAYER.instantiate()
		credits_amount.add_child(sound_player)
		sound_player.play()
	elif _previous_credits_amount > new_amount:
		var subtract_tween := create_tween()
		subtract_tween.tween_property(credits_amount, "modulate", subtraction_flash, subtraction_effect_time / 2)
		subtract_tween.tween_property(credits_amount, "modulate", _original_modulate, subtraction_effect_time / 2)
	_previous_credits_amount = new_amount
