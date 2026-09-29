class_name MovingPlatform
extends AnimatableBody2D

@export var travel_offset: Vector2 = Vector2(480, -128)
@export var travel_speed: float = 400.0
@export var pause_time: float = 1.0

var _start_position: Vector2

func _ready() -> void:
	_start_position = position
	var duration: float = travel_offset.length() / travel_speed
	var tween := create_tween()
	tween.set_loops()
	tween.tween_interval(pause_time)
	tween.tween_property(self, "position", _start_position + travel_offset, duration)
	tween.tween_interval(pause_time)
	tween.tween_property(self, "position", _start_position, duration)
