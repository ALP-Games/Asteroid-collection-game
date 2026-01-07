@tool
class_name MessageContainer extends Control

const GROUP = &"MessageContainerGroup"

const KEY_TRAVEL_PROGRESS = &"KeyTraveProgress"
const KEY_TRAVEL_AWAY_ACTIVE = &"KeyTavelAwayActive"

@export var label_scene: PackedScene
@export_tool_button("Add Message", "Callable") var _add_message_action = _tool_add_message
@export_group("Message behaviour")
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var default_message_life_time: float = 3.0
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var fade_in_time: float = 0.5
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var fade_out_time: float = 0.5
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var travel_time: float = 1.0
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var travel_away_time: float = 0.25

@export_range(0.0, 1.0, 0.001, "suffix:%") var center_offset: float = 0.5

var _message_queue: Array[Label]
var _message_targets: Dictionary


func _tool_add_message() -> void:
	var root := EditorInterface.get_edited_scene_root()
	add_message("Test message " + str(_message_queue.size() + 1))
	_message_queue[0].owner = root


func add_message(messsage: String, life_time := default_message_life_time) -> void:
	var new_message: Label = label_scene.instantiate()
	_message_queue.push_front(new_message)
	add_child(new_message)
	new_message.text = messsage
	
	new_message.modulate.a = 0.0
	
	_message_targets[new_message] = {
		KEY_TRAVEL_PROGRESS: 0.0,
		KEY_TRAVEL_AWAY_ACTIVE: false
	}
	
	new_message.minimum_size_changed.connect(func():
		new_message.size.x *= 2
		new_message.pivot_offset = new_message.size / 2
		new_message.position.x = size.x / 2 - new_message.size.x / 2
		new_message.position.y = _get_start_hgt()
		var fade_in_tween := create_tween()
		fade_in_tween.tween_property(new_message, "modulate:a", 1.0, fade_in_time)
		var fade_out_timer := get_tree().create_timer(life_time - fade_out_time)
		fade_out_timer.timeout.connect(func():
			var fade_out_tween := create_tween()
			fade_out_tween.tween_property(new_message, "modulate:a", 0.0, fade_out_time)
			)
		var travel_awat_timer := get_tree().create_timer(life_time - travel_away_time)
		travel_awat_timer.timeout.connect(func():
			var travel_away_tween := create_tween()
			var final_height := _get_end_hgt() - new_message.size.y
			_message_targets[new_message][KEY_TRAVEL_AWAY_ACTIVE] = true
			travel_away_tween.tween_property(new_message, "position:y", final_height, travel_away_time)
			)
		var life_timer := Timer.new()
		add_child(life_timer)
		life_timer.one_shot = true
		life_timer.timeout.connect(func():new_message.queue_free())
		life_timer.start(life_time)
		, CONNECT_ONE_SHOT)
	new_message.tree_exiting.connect(func():
		_message_queue.erase(new_message)
		_message_targets.erase(new_message)
		, CONNECT_ONE_SHOT)


func _ready() -> void:
	add_to_group(GROUP)


func _process(delta: float) -> void:
	if _message_queue.size() > 0:
		_process_messages(delta)
	
	#if not Engine.is_editor_hint():
		#if Input.is_action_just_pressed("reload"):
			#add_message("Test message " + str(_message_queue.size() + 1))


func _process_messages(delta: float) -> void:
	_process_message_height(_message_queue.back(), delta, _get_end_hgt())
	for index in range(_message_queue.size() - 2, -1, -1):
		var previous_message: Label = _message_queue[index + 1]
		var message: Label = _message_queue[index]
		var target_height := previous_message.position.y + previous_message.size.y
		_process_message_height(message, delta, target_height)


func _process_message_height(message: Label, delta: float, target_height: float) -> void:
	if _message_targets[message][KEY_TRAVEL_AWAY_ACTIVE]:
		return
	var travel_progress: float = _message_targets[message][KEY_TRAVEL_PROGRESS]
	travel_progress += delta / travel_time # for samll time keeping seems consistent enough
	travel_progress = min(travel_progress, 1.0)
	_message_targets[message][KEY_TRAVEL_PROGRESS] = travel_progress
	message.position.y = lerp(_get_start_hgt(), target_height, travel_progress)


func _get_start_hgt() -> float:
	return size.y


func _get_end_hgt() -> float:
	return center_offset * size.y
