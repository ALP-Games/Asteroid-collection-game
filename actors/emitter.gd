class_name Emitter extends Node3D

signal emitter_stopping
signal emitter_done

var _parent: RigidBody3D

func set_parent(parent: RigidBody3D) -> void:
	_parent = parent

func emit(target: Vector3) -> void:
	pass


func stop_emit() -> void:
	emitter_stopping.emit()
	emitter_done.emit()
