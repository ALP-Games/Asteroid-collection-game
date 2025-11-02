class_name DeployedCollector extends CollectionZone

@onready var collection_area: Area3D = $CollectionArea
@onready var collection_sound: AudioStreamPlayer3D = $CollectionSound
@onready var animation_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	collection_area.monitoring = false
	collection_sound.playing = false
	animation_tree.animation_finished.connect(_on_collector_deployed, CONNECT_ONE_SHOT)


func _on_collector_deployed(anim_name: StringName) -> void:
	if anim_name != &"mobilecollector_active":
		return
	collection_sound.playing = true
	collection_area.monitoring = true
