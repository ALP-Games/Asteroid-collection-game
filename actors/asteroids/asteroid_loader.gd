extends InstanceLoader


const KEY_SCALE = &"KeyAsteroidScale"

#asteroid_scale


@onready var _parent: Asteroid = get_parent()


func init_instance(meta_data: Dictionary) -> void:
	meta_data[KEY_SCALE] = _parent.asteroid_scale
	_parent.scale_changed.connect(func(new_scale: float)->void:
		meta_data[KEY_SCALE] = new_scale
		)


func load_instance(meta_data: Dictionary) -> void:
	_parent.set_mass_with_scale(meta_data[KEY_SCALE])
