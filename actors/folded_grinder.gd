class_name FoldedGrinder extends RigidBody3D

const DEPLOYED_COLLECTOR = preload("uid://d3y0gwfhn8my0")


var _interactor: InteractorComponent = null
var _deploy_interaction := HoldInteraction.new()
var _hold_e_gizmo: GizmoManager.GizmoProxy = null

func _ready() -> void:
	_deploy_interaction.hold_time = 0.5
	_deploy_interaction.interaction_callable = _deploy_collector


func _deploy_collector() -> void:
	var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
	var collector_instnace := DEPLOYED_COLLECTOR.instantiate() as Node3D
	instantiated_root.add_child(collector_instnace)
	collector_instnace.global_position = global_position
	collector_instnace.rotation.y = rotation.y
	queue_free()


func _on_interaction_area_body_entered(body: Node3D) -> void:
	InteractorComponent.core().invoke_on_component(body, _add_interaction)


func _on_interaction_area_body_exited(body: Node3D) -> void:
	InteractorComponent.core().invoke_on_component(body, _remove_interaction)


func _add_interaction(interaction_component: InteractorComponent) -> void:
	if _interactor:
		return
	_interactor = interaction_component
	_hold_e_gizmo = (get_tree().get_first_node_in_group("gizmo_manager") as GizmoManager).get_hold_e_gizmo_proxy(self)
	interaction_component.add_interaction(_deploy_interaction)
	
	#interaction_component.get_interaction()


func _remove_interaction(interaction_component: InteractorComponent) -> void:
	_hold_e_gizmo.disable()
	_interactor = null
	_hold_e_gizmo = null
	interaction_component.remove_interaction(_deploy_interaction)


func _process(_delta: float) -> void:
	if _interactor and _interactor.get_interaction() == _deploy_interaction:
		assert(_hold_e_gizmo, "Should be a valid proxy reference!")
		_hold_e_gizmo.enable()
		var gizmo_instance: HoldEGizmo = _hold_e_gizmo.get_gizmo()
		if gizmo_instance.is_node_ready():
			gizmo_instance.set_progress(100.0 - _deploy_interaction.get_progress() * 100.0)
		# Enable gizmo
		pass
