extends InstanceLoader

const KEY_UNLATCHED = &"KeyShopUnlatched"

@onready var shop_latch: LatchMechanism = $"../ShopLatch"
@onready var unlatch_parts: Array[Node3D] = [$"../DeadLock", $"../DeadLock2", $"../ShopLatch", $"../ShopLatch2"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().ready.connect(func():
		if GameManager.save_data.fresh_load:
			init_instance(GameManager.save_data.save_meta_data)
		else:
			load_instance(GameManager.save_data.save_meta_data)
		, CONNECT_ONE_SHOT)
	shop_latch.unlatched.connect(_update_unlatch, CONNECT_ONE_SHOT)

# how do we load that shit?
# shop zone script has to call one of these functions
# I guess we can check for "fresh save" and that's it?


func _update_unlatch() -> void:
	GameManager.save_data.save_meta_data[KEY_UNLATCHED] = true


func init_instance(meta_data: Dictionary) -> void:
	meta_data[KEY_UNLATCHED] = false


func load_instance(meta_data: Dictionary) -> void:
	if meta_data.get(KEY_UNLATCHED, false):
		for part in unlatch_parts:
			part.queue_free()
		$"..".enable_handles_skip_animation()
	else:
		# I don't think we need to do anything
		pass
