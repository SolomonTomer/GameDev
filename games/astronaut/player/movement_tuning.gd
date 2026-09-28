class_name MovementTuning
extends Resource

@export var run_speed: float = 350.0
@export var gravity: float = 1536.0

## Negative (upward). Jump height is fixed; holding the button longer does not jump higher.
@export var jump_velocity: float = -768.0

@export_range(0.0, 1.0) var air_control: float = 1.0
@export var coyote_time: float = 0.2
@export var jump_buffer_time: float = 0.2
