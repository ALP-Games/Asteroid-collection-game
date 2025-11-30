class_name ItemDispenser extends Node3D

# I think we should queue items in the dispensor
# and then they get spawned once it's unocupied

@export var color_avaliable: Color = Color.GREEN
@export var color_occupied: Color = Color.RED

var dispensor_item_queue: Array[PackedScene]

@onready var dispensing_area: Area3D = $DispensingArea
@onready var avaliability_indicator: OmniLight3D = $AvaliabilityIndicator


func _ready() -> void:
	dispensing_area.global_position.y = 0.0
	_check_avaliability()


func _physics_process(_delta: float) -> void:
	_check_avaliability()


func add_item_to_dispense(scene: PackedScene) -> void:
	dispensor_item_queue.push_back(scene)


func _check_avaliability() -> void:
	if dispensing_area.get_overlapping_bodies().size() > 0:
		avaliability_indicator.light_color = color_occupied
	else:
		avaliability_indicator.light_color = color_avaliable
		_dispense_item()


func _dispense_item() -> void:
	if dispensor_item_queue.size() > 0:
		var item := dispensor_item_queue.pop_front() as PackedScene
		var instance := item.instantiate() as Node3D
		get_tree().get_first_node_in_group("instantiated_root").add_child(instance)
		instance.global_position = dispensing_area.global_position
