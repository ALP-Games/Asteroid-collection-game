## Functionality for hookable objects
class_name HookableComponent
extends Component

signal object_hooked
signal object_unhooked

var hooked: bool = false
var hook_object: Hook = null
@onready var unhook_selection: MaterialOverlayer = $"../UnhookSelection"

var right_click_gizmo: GizmoManager.GizmoProxy = null

static func core() -> ComponentCore:
	return ComponentCore.new(HookableComponent)


func _ready() -> void:
	set_physics_process(false)
	right_click_gizmo = (get_tree().get_first_node_in_group("gizmo_manager") as GizmoManager).get_right_click_proxy(get_parent())
	var mouse_over_component: MouseOverComponent = MouseOverComponent.core().get_from(get_parent())
	if mouse_over_component: # FOR DEBUG ONLY, why for debug? :thinking:
		mouse_over_component.on_mouse_enter.connect(func():
			#var gizmo_manager := get_tree().get_first_node_in_group("gizmo_manager") as GizmoManager
			# need to give gizmo
			# and if gizmo not needed then remove it
			# maybe we need to save the gizmo UI?
			# or get the gizmo in _physics_process?
			# or need to get reference to gizmo or something that is associated with this object?
			# how to make this least retarded?
			# now it's waaaay worse than it was
			
			# GizmoManager
			# get gizmo "owner" from GizmoManager?
			# get gizmo from the "owner"?
			# do we clean up owners or?
			# if gizmo not enabled it should not have an instance
			# we should track - there might be a gizmo?
			# we need a Gizmo Interface class?
			# all gizmos need to follow some kind of transform3D or whatever
			
			#right_click_gizmo = gizmo_manager.add_right_cick_gizmo()
			#right_click_gizmo = get_tree().get_first_node_in_group("right_click_gizmo")
			#right_click_gizmo.node_to_follow = get_parent()
			set_physics_process(true))
		mouse_over_component.on_mouse_exit.connect(func():
			set_physics_process(false)
			#if right_click_gizmo.enabled():
			right_click_gizmo.disable()
			if unhook_selection.overlay_active():
				unhook_selection.reset_overlayed_material())


func _physics_process(delta: float) -> void:
	if not hooked:
		if unhook_selection.overlay_active():
			unhook_selection.reset_overlayed_material()
		right_click_gizmo.disable()
		#if right_click_gizmo.enabled():
		return
	#if not right_click_gizmo.enabled():
	right_click_gizmo.enable()
		#right_click_gizmo.enable_on(get_parent())
	if not unhook_selection.overlay_active():
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
