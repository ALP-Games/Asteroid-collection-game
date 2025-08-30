class_name PriorityQueue extends RefCounted

var queue: Array[PriorityQueueItem]

func add_item(item: PriorityQueueItem) -> void:
	var insert_pos := 0
	for index in queue.size():
		var other_item := queue[index] as PriorityQueueItem
		if item.priority > other_item.priority:
			insert_pos = index
			break
	queue.insert(insert_pos, item)


func get_first_item() -> PriorityQueueItem:
	return queue.front()


func pop_first_item() -> PriorityQueueItem:
	return queue.pop_front()


func remove_item(item: PriorityQueueItem) -> void:
	queue.erase(item)
