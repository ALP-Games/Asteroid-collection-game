class_name DeployedCollector extends CollectionZone

@onready var collection_area: Area3D = $CollectionArea
@onready var animation_player: AnimationPlayer = $rocket_base_a2/AnimationPlayer


func _ready() -> void:
	collection_area.monitoring = false
	animation_player.play(&"mobilecollector_active")
	animation_player.animation_finished.connect(_on_collector_deployed, CONNECT_ONE_SHOT)


func _on_collector_deployed(anim_name: StringName) -> void:
	if anim_name != &"mobilecollector_active":
		return
	animation_player.play("Shreder")
	collection_area.monitoring = true
