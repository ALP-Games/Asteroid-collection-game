@abstract class_name InstanceLoader extends Component


static func core() -> ComponentCore:
	return ComponentCore.new(InstanceLoader)


@abstract func init_instance(meta_data: Dictionary) -> void
@abstract func load_instance(meta_data: Dictionary) -> void
