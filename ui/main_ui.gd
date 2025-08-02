class_name MainUI extends Control

@onready var credits_amount: Label = $LayoutsContainer/HBoxContainer/Amount


func _ready() -> void:
	GameManager.credits_amount_changed.connect(on_credit_amount_changed)
	on_credit_amount_changed(GameManager.credist_amount)

func on_credit_amount_changed(new_amount: int) -> void:
	credits_amount.text = str(new_amount)
