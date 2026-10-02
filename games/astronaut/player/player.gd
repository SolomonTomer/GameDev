class_name Player
extends CharacterBody2D

@export var tuning: MovementTuning

@onready var _jump_sound: AudioStreamPlayer = $JumpSound
@onready var _land_sound: AudioStreamPlayer = $LandSound

var _coyote_time_left: float = 0.0
var _jump_buffer_time_left: float = 0.0
var _controls_enabled: bool = true
var _was_on_floor: bool = true

func set_controls_enabled(enabled: bool) -> void:
	_controls_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not _controls_enabled:
		return

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
		_jump_sound.play()

	move_and_slide()

	var on_floor_now: bool = is_on_floor()
	if on_floor_now and not _was_on_floor:
		_land_sound.play()
	_was_on_floor = on_floor_now
