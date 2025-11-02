class_name HoldInteraction extends Interaction

var hold_to_interact: bool = false
var hold_time: float = 0.5
var _timer: SceneTreeTimer = null

var _interaction_hit: bool = false


## UNDESTED CODE, ESPECIALLY is_zero_approx(timer.time_left)
func interact(is_just_pressed: bool, is_pressed: bool) -> void:
	if is_just_pressed:
		_interaction_hit = false
		_timer = GameManager.get_tree().create_timer(hold_time, false, false, false)
	if not is_pressed and _timer:
		_timer = null
	if _timer and is_zero_approx(_timer.time_left) and not _interaction_hit:
		_interaction_hit = true
		_call_interaction()
	# could be emmiting progress to ui or something


func get_progress() -> float:
	if _timer:
		return 1.0 - _timer.time_left / hold_time
	return 0.0
