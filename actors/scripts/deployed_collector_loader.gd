extends InstanceLoader

const KEY_DEPLOYED = &"KeyDeployed"

@onready var _parent: DeployedCollector = get_parent()

func init_instance(meta_data: Dictionary) -> void:
	meta_data[KEY_DEPLOYED] = true


func load_instance(meta_data: Dictionary) -> void:
	if meta_data.get(KEY_DEPLOYED, false):
		_parent.activate_grinding()
	else:
		meta_data[KEY_DEPLOYED] = true
