class_name GizmoCountUp extends GizmoOverNode3D

@onready var counter_label: Label = $Counter
@onready var suffix: Label = $Suffix

@export var count_up_time := 1.0
@export var delay_after_coutup := 0.5
@export var scale_pulse := 1.1
@export var scale_burst := 0.2
@export var burst_time := 0.05
@export var travel_time := 0.2

@export_group("Multiplier effects")
@export var delay_before_multiplier := 0.4
@export var multiplier_appear_time := 0.1
@export var delay_before_multiplier_add := 0.2
@export var multiplier_add_time := 0.1
@export var multiply_pop_scale := 1.2
@export var multiply_pop_time := 0.2
@export var reduce_wait_time := 0.2

var counter_value := 0

var _current_counter_value := 0
var _gizmo_position: Vector3
var _destination: Vector2
var _travel_amount := 0.0

func _ready() -> void:
	super()
	physics_interpolation_mode = PHYSICS_INTERPOLATION_MODE_OFF
	modulate.a = 1.0
	counter_label.text = str(_current_counter_value)
	suffix.text = ""
	_destination = (get_tree().get_first_node_in_group("credits_counter_label") as Control).global_position


func _process(_delta: float) -> void:
	var origination_pos := camera.unproject_position(_gizmo_position)
	var viewport_size := camera.get_viewport().get_visible_rect().size
	origination_pos.y = clampf(origination_pos.y, -counter_label.position.y, viewport_size.y - counter_label.size.y - counter_label.position.y)
	origination_pos.x = clampf(origination_pos.x, -counter_label.position.x, viewport_size.x - counter_label.size.x)
	
	position = lerp(origination_pos, _destination, _travel_amount)
	#position = origination_pos
	
	counter_label.text = str(_current_counter_value)


func enable() -> void:
	if state == State.ENABLED or state == State.ENABLING:
		return
	state = State.ENABLING
	visible = true
	_gizmo_position = node_to_follow.get_global_transform_interpolated().origin
	
	var multiplier := GameManager.get_multiplier()
	var enable_multiplier_effects := multiplier != 1.0
	
	var grow_tween := create_tween()
	grow_tween.tween_property(self, "scale", Vector2(scale_pulse, scale_pulse),
		count_up_time * (1.0 - burst_time))\
		.set_trans(Tween.TRANS_LINEAR)
	grow_tween.tween_property(self, "scale",
		Vector2(scale_pulse + scale_burst, scale_pulse + scale_burst),
		count_up_time * burst_time)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		
	var delay_before_travel := delay_after_coutup
	
	if enable_multiplier_effects:
		grow_tween.tween_interval(delay_before_multiplier)
		grow_tween.tween_callback(func():
			suffix.text = "* " + str(multiplier)
			suffix.position.x = counter_label.size.x - counter_label.position.x
			suffix.scale.y = 0.0
			var suffix_tween := create_tween()
			suffix_tween.tween_property(suffix, "scale:y", 1.0, multiplier_appear_time)\
				.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			suffix_tween.tween_property(suffix, "position:x",
				counter_label.position.x, multiplier_add_time)\
				.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)\
				.set_delay(delay_before_multiplier_add)
			suffix_tween.tween_callback(func():
				# this multiplier should also guarantee at least +1
				_current_counter_value = ceili(_current_counter_value * multiplier)
				suffix.text = ""
				var pop_tween := create_tween()
				pop_tween.tween_property(counter_label, "scale", Vector2.ONE * multiply_pop_scale, multiply_pop_time / 2)
				pop_tween.tween_property(counter_label, "scale", Vector2.ONE, multiply_pop_time / 2)
				)
			#counter_value
			# deffinetly should not write to the same one
			)
		delay_before_travel += (delay_before_multiplier + multiplier_appear_time + 
			multiplier_add_time + delay_before_multiplier_add + multiply_pop_time - reduce_wait_time)
	
	var count_up := create_tween()
	count_up.tween_property(self, "_current_counter_value", counter_value, count_up_time)
	count_up.tween_callback(func():
		var float_up_tween := create_tween()
		float_up_tween.tween_property(self, "_travel_amount", 1.0, travel_time)
		float_up_tween.tween_callback(func():
			if state == State.ENABLING:
				finished_enabling.emit()
				state = State.ENABLED
				GameManager.credist_amount += counter_value
				queue_free()
				# update money only here
			)).set_delay(delay_before_travel)
	set_process(true)


func disable() -> void:
	if state == State.DISABLED or state == State.DISABLING:
		return
	visible = false
	state = State.DISABLED
	_current_counter_value = 0
	set_process(false)
