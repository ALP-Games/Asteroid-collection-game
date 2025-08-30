class_name HoldInteraction extends Interaction

var hold_to_interact: bool = false
var hold_time: float = 0.5
var timer: SceneTreeTimer = null


## UNDESTED CODE, ESPECIALLY is_zero_approx(timer.time_left)
func interact(is_just_pressed: bool, is_pressed: bool) -> void:
	if is_just_pressed:
		if timer:
			timer.free() # is it safe to do this to a SceneTreeTimer?
		timer = GameManager.get_tree().create_timer(hold_time, false, true, true)
	if not is_pressed and timer:
		timer.free()
	if timer and is_zero_approx(timer.time_left):
		_call_interaction()
	# could be emmiting progress to ui or something
