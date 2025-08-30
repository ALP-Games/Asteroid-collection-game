class_name InteractorComponent extends Component

#var interaction_queue: Array = []
var interaction_queue := PriorityQueue.new()


static func core() -> ComponentCore:
	return ComponentCore.new(InteractorComponent)


func add_interaction(interaction: Interaction) -> void:
	interaction_queue.add_item(interaction)


func remove_interaction(interaction: Interaction) -> void:
	interaction_queue.remove_item(interaction)


func get_interaction() -> Interaction:
	return interaction_queue.get_first_item()
