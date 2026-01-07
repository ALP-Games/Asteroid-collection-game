class_name ButtonWithSounds extends Button

const CLICK_SOUND_PLAYER := preload("uid://b2wuithykkaes")
const MOUSE_ENTERED_SOUND_PLAYER := preload("uid://mchn2r1k3y8q")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(_play_sound.bind(CLICK_SOUND_PLAYER))
	mouse_entered.connect(_on_hover)


func _on_hover() -> void:
	if disabled:
		return
	_play_sound(MOUSE_ENTERED_SOUND_PLAYER)


func _play_sound(sound_scene: PackedScene) -> void:
	var audio_player_instance = sound_scene.instantiate() as AudioStreamPlayer
	get_tree().root.add_child(audio_player_instance)
	audio_player_instance.play()
	audio_player_instance.finished.connect(func():audio_player_instance.queue_free(), CONNECT_ONE_SHOT)
