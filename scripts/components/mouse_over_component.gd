## Component to be notified if the object was moused over
class_name MouseOverComponent
extends Component

signal on_mouse_enter
signal on_mouse_exit

static func core() -> ComponentCore:
	return ComponentCore.new(MouseOverComponent)


func mouse_entered() -> void:
	on_mouse_enter.emit()


func mouse_exited() -> void:
	on_mouse_exit.emit()
