class_name PhysicsStateSave extends Component


var _parent: RigidBody3D


static func core() -> ComponentCore:
	return ComponentCore.new(PhysicsStateSave)


func _ready() -> void:
	_parent = get_parent()
