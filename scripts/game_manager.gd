extends Node

signal credits_amount_changed(new_amount: int)

var upgrade_data := UpgradeData.new()

var credist_amount: int = 0:
	set(value):
		credist_amount = value
		credits_amount_changed.emit(credist_amount)
	
