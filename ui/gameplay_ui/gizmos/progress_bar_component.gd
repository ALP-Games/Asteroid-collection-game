class_name ProgressBarComponent extends Component

@export var progress_bar: TextureProgressBar

var _progress: float = 0.0

static func core() -> ComponentCore:
	return ComponentCore.new(ProgressBarComponent)


func _ready() -> void:
	progress_bar.value = _progress


func set_progress(progress: float) -> void:
	_progress = progress
	if is_node_ready() and progress_bar.is_node_ready():
		progress_bar.value = _progress
