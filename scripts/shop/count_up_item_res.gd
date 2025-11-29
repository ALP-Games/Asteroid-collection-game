class_name CountUpItemRes extends ShopItemRes

var current_data_instance: ShopEntry

func get_entry(index: int) -> ShopEntry:
	current_data_instance = super(index).duplicate()
	current_data_instance.price = data.price * (index + 1)
	return current_data_instance
