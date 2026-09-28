class_name Player
extends CharacterBody2D

@export var tuning: MovementTuning

var _coyote_time_left: float = 0.0
var _jump_buffer_time_left: float = 0.0

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_coyote_time_left = tuning.coyote_time
	else:
		_coyote_time_left = maxf(_coyote_time_left - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_time_left = tuning.jump_buffer_time
	else:
		_jump_buffer_time_left = maxf(_jump_buffer_time_left - delta, 0.0)

	velocity.y += tuning.gravity * delta

	var direction: float = Input.get_axis("left", "right")
	var control: float = 1.0 if is_on_floor() else tuning.air_control
	velocity.x = direction * tuning.run_speed * control

	if _jump_buffer_time_left > 0.0 and _coyote_time_left > 0.0:
		velocity.y = tuning.jump_velocity
		_jump_buffer_time_left = 0.0
		_coyote_time_left = 0.0

	move_and_slide()
