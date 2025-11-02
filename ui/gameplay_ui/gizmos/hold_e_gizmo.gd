class_name HoldEGizmo extends GizmoOverNode3D

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var _progress: float


func _ready() -> void:
	super()
	texture_progress_bar.value = 100


func _process(delta: float) -> void:
	super(delta)
	texture_progress_bar.value = _progress


func set_progress(progress: float) -> void:
	_progress = progress
