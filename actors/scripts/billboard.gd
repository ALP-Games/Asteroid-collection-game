extends RigidBody3D

@onready var _handles: Array[Handle] = [$Handle, $Handle2]
@onready var _decelerator_component: DeceleratorComponent = $DeceleratorComponent

var _hooked_places_count: int = 0
var _total_mass: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for handle in _handles:
		HookableComponent.core().invoke_on_component(handle, func(hookable: HookableComponent)->void:
			hookable.object_hooked.connect(_process_hooked_places_count.bind(true))
			hookable.object_unhooked.connect(_process_hooked_places_count.bind(false)))
	_total_mass = mass
	var handle_array: Array = get_meta(Handle.HANDLE_META, [])
	for handle: RigidBody3D in handle_array:
		_total_mass += handle.mass


func _process_hooked_places_count(hooked: bool) -> void:
	if hooked:
		_hooked_places_count += 1
		_decelerator_component.decelerate = false
	else:
		_hooked_places_count -= 1
	
	if _hooked_places_count == 0:
		_decelerator_component.decelerate = true


func get_total_mass() -> float:
	return _total_mass


func enable_handles() -> void:
	_handles.all(func(handle):
		handle.start_enablement_animation()
		return true)
