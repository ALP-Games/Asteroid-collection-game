class_name GizmoManager extends Control

const RIGHT_CLICK_GIZMO = preload("uid://cgjsot8bv83rv")

## SESSION MIGHT NOT BE NEEDED!
#class GizmoSession extends RefCounted:
	#var _manager_ref: GizmoManager
	#var owner_ref: RefCounted # is this needed even?
	#
	#func _init(manager_ref: GizmoManager) -> void:
		#_manager_ref = manager_ref
	
	# maybe instead it should return a gizmo representation or something?
	# and when enabling representation it actually gets intantiated or something like that?
	# Am I trying to overengineer this system?
	
	# Gizmo Manager goals:
	# 1. Every instance that once to have access to gizmos should only be able to instantiate only 1 gizmo per type
	#	* this is accomplished with the "GizmoSession"
	# 2. Gizmos should not have Node instances if not actually visible
	#	* makes no sense to create multiple functions for each gizmo
	#	* do I really need to create another class or something that could instantiate a gizmo if needed?
	#	* do we really need a "GizmoSession"?
	#	* If I only have that other class that enables/hides a gizmo then I would do gizmo overlaying?
	#	* or maybe for the gizmos that follow my object I can somehow distinguish who owns it because I pass an object to it?
	#	* It looks like I 100% need that Gizmo proxy class
	#func get_right_click_gizmo() -> IGizmo:
		#return null


class GizmoProxy extends RefCounted:
	
	enum State
	{
		TRANSIENT,
		ENABLED,
		DISABLED
	}
	
	var _manager: GizmoManager
	var _gizmo_instantiation_func: Callable
	var _gizmo_instance: IGizmo = null
	var _state: State = State.TRANSIENT
	
	
	func _init(manager: GizmoManager, instantiation: Callable) -> void:
		_manager = manager
		_gizmo_instantiation_func = instantiation
	
	
	func enable() -> void:
		if not _gizmo_instance:
			_gizmo_instance = _gizmo_instantiation_func.call()
			_manager.add_child(_gizmo_instance)
		if _state == State.ENABLED:
			return
		_state = State.TRANSIENT
		_gizmo_instance.enable()
		if not _gizmo_instance.finished_enabling.is_connected(_gizmo_enabled):
			_gizmo_instance.finished_enabling.connect(_gizmo_enabled, CONNECT_ONE_SHOT)
	
	
	func disable() -> void:
		if _state == State.DISABLED:
			return
		_state = State.TRANSIENT
		if not _gizmo_instance:
			return
		_gizmo_instance.disable()
		if not _gizmo_instance.finished_disabling.is_connected(_gizmo_disabled):
			_gizmo_instance.finished_disabling.connect(_gizmo_disabled, CONNECT_ONE_SHOT)
	
	
	func _gizmo_enabled() -> void:
		_state = State.ENABLED
	
	
	func _gizmo_disabled() -> void:
		_state = State.DISABLED
		if _gizmo_instance:
			_gizmo_instance.queue_free()


func _enter_tree() -> void:
	add_to_group("gizmo_manager")


# we add it
# then the user enables it?
# I think the user shoud not be enabing it
func add_right_cick_gizmo() -> IGizmo:
	var instance := RIGHT_CLICK_GIZMO.instantiate() as IGizmo
	add_child(instance)
	return instance


func get_right_click_proxy(node_to_follow: Node3D) -> GizmoProxy:
	return GizmoProxy.new(self, func() -> IGizmo:
		var gizmo := RIGHT_CLICK_GIZMO.instantiate() as GizmoOverNode3D
		gizmo.node_to_follow = node_to_follow
		return gizmo)
