class_name ButtonWithSounds extends Button

const CLICK_SOUND_PLAYER := preload("uid://b2wuithykkaes")
const MOUSE_ENTERED_SOUND_PLAYER := preload("uid://mchn2r1k3y8q")

var click_sound_scene := CLICK_SOUND_PLAYER
var mouse_enterd_sound_scene := MOUSE_ENTERED_SOUND_PLAYER 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(func():_play_sound(click_sound_scene))
	mouse_entered.connect(_on_hover)


func _on_click() -> void:
	_play_sound(click_sound_scene)


func _on_hover() -> void:
	if disabled:
		return
	_play_sound(mouse_enterd_sound_scene)


func _play_sound(sound_scene: PackedScene) -> void:
	var audio_player_instance = sound_scene.instantiate() as AudioStreamPlayer
	get_tree().root.add_child(audio_player_instance)
	audio_player_instance.play()
	audio_player_instance.finished.connect(func():audio_player_instance.queue_free(), CONNECT_ONE_SHOT)
