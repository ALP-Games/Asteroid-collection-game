class_name MainUI extends Control

@onready var credits_amount: Label = $LayoutsContainer/HBoxContainer/CreditsAmountControl/Amount
@onready var _original_modulate := credits_amount.modulate

@export_group("Addition effect")
@export var credits_pop_scale := 1.2
@export var credits_pop_time := 0.2
@export_group("Subtraction effect")
@export var subtraction_flash := Color.RED
@export var subtraction_effect_time := 0.2

var _previous_credits_amount := 0

func _ready() -> void:
	_previous_credits_amount = GameManager.credist_amount
	GameManager.credits_amount_changed.connect(on_credit_amount_changed)
	on_credit_amount_changed(GameManager.credist_amount)


func on_credit_amount_changed(new_amount: int) -> void:
	credits_amount.text = str(new_amount)
	if _previous_credits_amount < new_amount:
		var pop_tween := create_tween()
		pop_tween.tween_property(credits_amount, "scale", Vector2.ONE * credits_pop_scale, credits_pop_time / 2)
		pop_tween.tween_property(credits_amount, "scale", Vector2.ONE, credits_pop_time / 2)
	elif _previous_credits_amount > new_amount:
		var subtract_tween := create_tween()
		subtract_tween.tween_property(credits_amount, "modulate", subtraction_flash, subtraction_effect_time / 2)
		subtract_tween.tween_property(credits_amount, "modulate", _original_modulate, subtraction_effect_time / 2)
	_previous_credits_amount = new_amount
