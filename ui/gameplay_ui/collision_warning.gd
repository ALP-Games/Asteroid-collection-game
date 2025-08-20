class_name CollisionWarning extends WarningBox

const COUNTDOWN_FORMAT = &"%1.1fs"

@export var linger_time := 0.5

@export var recalibration_success: Label
@export var countdown_text: Label

var countdown: float = 0.0

func _ready() -> void:
	super()
	if recalibration_success:
		recalibration_success.visible = false
	set_process(false)

func set_timer_and_show(cdwn: float) -> void:
	countdown = cdwn
	show_warning()
	set_process(true)
	_update_countdown()


func _process(delta: float) -> void:
	countdown -= delta
	if countdown <= 0.0:
		set_process(false)
		#hide_warning()
		if recalibration_success:
			recalibration_success.visible = true
		get_tree().create_timer(linger_time).timeout.connect(func():
			if recalibration_success:
				recalibration_success.visible = false
			hide_warning()
			)
		countdown = 0.0
	_update_countdown()


func _update_countdown() -> void:
	if countdown_text:
		countdown_text.text = COUNTDOWN_FORMAT % countdown
