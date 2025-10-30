@abstract class_name IGizmo extends Control

# Gizmo - has visual aspect
# has _process function - a custom one should be set for a gizmo
# needs an enable and disable functions
# I guess would need signals fro when it has materialized and de-materialized, so that managers would know what's happening
# does it need to be like this? Maybe should be just an Interface?

signal finished_enabling
signal finished_disabling


#@abstract func _ready() -> void
#
#@abstract func _process(delta: float) -> void

@abstract func enable() -> void

@abstract func disable() -> void

@abstract func is_enabled() -> bool
