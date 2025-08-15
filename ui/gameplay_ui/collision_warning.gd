class_name CollisionWarning extends WarningBox

const COUNTDOWN_FORMAT = &"%1.1fs"

@export var linger_time := 0.5

@onready var recalibration_success: Label = $RecalibrationEstate/RecalibrationSuccess
@onready var countdown_text: Label = $RecalibrationEstate/RecalibrationCountdown/CountdownText

var countdown: float = 0.0

func _ready() -> void:
	super()
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
		recalibration_success.visible = true
		get_tree().create_timer(linger_time).timeout.connect(func():
			recalibration_success.visible = false
			hide_warning()
			)
		countdown = 0.0
	_update_countdown()


func _update_countdown() -> void:
	countdown_text.text = COUNTDOWN_FORMAT % countdown
