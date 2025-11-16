@tool
class_name FollowNodes extends Node

@export var nodes_to_follow: Array[Node3D]
@export var following_nodes: Array[Node3D]
#@export var update_follow_nodes: bool = true

var update_follow_nodes: bool = false

var update_follow_nodes_func: Callable


func _ready() -> void:
	if Engine.is_editor_hint():
		update_follow_nodes_func = _editor_update_follow_nodes
	else:
		update_follow_nodes_func = _runtime_update_follow_nodes


func _process(_delta: float) -> void:
	update_follow_nodes_func.call()


func _editor_update_follow_nodes() -> void:
	for index in following_nodes.size():
		var following_node := following_nodes[index]
		var node_to_follow := nodes_to_follow[index]
		if not following_node or not node_to_follow:
			continue
		following_node.global_transform = node_to_follow.global_transform


func _runtime_update_follow_nodes() -> void:
	if not update_follow_nodes:
		return
	refresh()


func refresh() -> void:
	for index in following_nodes.size():
		var following_node := following_nodes[index]
		var node_to_follow := nodes_to_follow[index]
		following_node.global_transform = node_to_follow.global_transform
