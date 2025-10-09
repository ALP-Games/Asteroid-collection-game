## Functionality for hookable objects
class_name HookableComponent
extends Component

signal object_hooked
signal object_unhooked

var hooked: bool = false
var hook_object: Hook
@onready var unhook_selection: MaterialOverlayer = $"../UnhookSelection"

static func core() -> ComponentCore:
	return ComponentCore.new(HookableComponent)


func _ready() -> void:
	set_physics_process(false)
	var mouse_over_component: MouseOverComponent = MouseOverComponent.core().get_from(get_parent())
	if mouse_over_component: # FOR DEBUG ONLY
		mouse_over_component.on_mouse_enter.connect(func():
			set_physics_process(true))
		mouse_over_component.on_mouse_exit.connect(func():
			set_physics_process(false)
			if unhook_selection.overlay_active():
				unhook_selection.reset_overlayed_material())


func _physics_process(delta: float) -> void:
	if not unhook_selection.overlay_active() and hooked:
		unhook_selection.overlay_material()
	if Input.is_action_just_pressed("action2"):
		hook_object.parent_emitter.stop_emit()
		pass


func hook(hook_obj: Hook) -> void:
	if not hooked:
		hook_object = hook_obj
		hooked = true
		object_hooked.emit()


func unhook() -> void:
	if hooked:
		hook_object = null
		hooked = false
		object_unhooked.emit()
