class_name GrinderBeacon extends RigidBody3D

const DEPLOYED_COLLECTOR = preload("uid://d3y0gwfhn8my0")

var _deploy_interaction := HoldInteraction.new()
var _hold_e_gizmo: GizmoManager.GizmoProxy = null

var _interactor_in_range: InteractorComponent = null
var _interaction_added: bool = false
var _buildings_in_range: int = 0

@onready var _hookable_component: HookableComponent = $HookableComponent
@onready var _decelerator_component: DeceleratorComponent = $DeceleratorComponent


func _ready() -> void:
	_deploy_interaction.hold_time = 0.5
	_deploy_interaction.interaction_callable = _deploy_collector
	
	_hookable_component.object_hooked.connect(func():_decelerator_component.decelerate = false)
	_hookable_component.object_unhooked.connect(func():_decelerator_component.decelerate = true)


func _deploy_collector() -> void:
	var instantiated_root := get_tree().get_first_node_in_group("instantiated_root")
	var collector_instnace := DEPLOYED_COLLECTOR.instantiate() as Node3D
	instantiated_root.add_child(collector_instnace)
	collector_instnace.global_position = global_position
	collector_instnace.rotation.y = rotation.y
	queue_free()


func _on_interaction_area_body_entered(body: Node3D) -> void:
	InteractorComponent.core().invoke_on_component(body, _add_interactor)
	_check_interaction()


func _on_interaction_area_body_exited(body: Node3D) -> void:
	InteractorComponent.core().invoke_on_component(body, _remove_interactor)
	_check_interaction()


func _on_building_detection_body_entered(_body: Node3D) -> void:
	_buildings_in_range += 1
	_check_interaction()


func _on_building_detection_body_exited(_body: Node3D) -> void:
	_buildings_in_range -= 1
	_check_interaction()


func _check_interaction() -> void:
	assert(_buildings_in_range >= 0)
	if not _interaction_added and _interactor_in_range and _buildings_in_range == 0:
		_interaction_added = true
		_interactor_in_range.add_interaction(_deploy_interaction)
		if not _hold_e_gizmo:
			_hold_e_gizmo = (get_tree().get_first_node_in_group("gizmo_manager") as GizmoManager).get_hold_e_gizmo_proxy(self)
	elif _interaction_added and _interactor_in_range and  _buildings_in_range > 0:
		_interaction_added = false
		_interactor_in_range.remove_interaction(_deploy_interaction)
		_hold_e_gizmo.disable()


func _add_interactor(interaction_component: InteractorComponent) -> void:
	if _interactor_in_range:
		return
	_interactor_in_range = interaction_component


func _remove_interactor(interaction_component: InteractorComponent) -> void:
	if interaction_component == _interactor_in_range:
		_interactor_in_range.remove_interaction(_deploy_interaction)
		_interactor_in_range = null
		_interaction_added = false
		if _hold_e_gizmo:
			_hold_e_gizmo.disable()
			_hold_e_gizmo = null


func _process(_delta: float) -> void:
	if _interactor_in_range and _interactor_in_range.get_interaction() == _deploy_interaction:
		assert(_hold_e_gizmo, "Should be a valid proxy reference!")
		_hold_e_gizmo.enable()
		var gizmo_instance := _hold_e_gizmo.get_gizmo()
		if gizmo_instance.is_node_ready():
			var progress_bar: ProgressBarComponent = ProgressBarComponent.core().get_from(gizmo_instance)
			progress_bar.set_progress(_deploy_interaction.get_progress() * 100.0)
