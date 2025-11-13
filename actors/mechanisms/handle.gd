@tool
class_name Handle extends RigidBody3D

@export var starting_angle: float
@export var target_angle: float
@export var rotation_animation_duration: float = 0.5

@export var show_target_instead_of_starting: bool = false
@export var play_rotation_animation: bool = false


# TODO: add smooth rotation to desegnated position
# add a function that can be bound to a signal to do so
