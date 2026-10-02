class_name Rocket
extends Area2D

signal needs_parts
signal launched

const LAUNCH_RISE := 1400.0
const EXCITED_ANGLES: Array[float] = [-3.0, 3.0, -2.5, 2.5, 0.0]
const HOP_HEIGHT := 8.0

var _ready_to_launch: bool = false
var _launching: bool = false
var _idle_tween: Tween
var _glow_tween: Tween
var _hop_tween: Tween
var _glow_base_scale: Vector2
var _visual_base_y: float

@onready var _visual: Node2D = $Visual
@onready var _glow: Sprite2D = $Glow
@onready var _flame: AnimatedSprite2D = $Visual/Flame
@onready var _engine: Sprite2D = $Visual/Engine
@onready var _window_lit: Sprite2D = $Visual/WindowLit
@onready var _window_astronaut: Sprite2D = $Visual/WindowAstronaut
@onready var _door: AnimatedSprite2D = $Visual/Door
@onready var _sparkles: CPUParticles2D = $Visual/Sparkles
@onready var _smoke_burst: CPUParticles2D = $Visual/SmokeBurst
@onready var _smoke_trail: CPUParticles2D = $Visual/SmokeTrail
@onready var _attach_sparks: CPUParticles2D = $Visual/AttachSparks
@onready var _door_close_sound: AudioStreamPlayer = $DoorCloseSound
@onready var _engine_attach_sound: AudioStreamPlayer = $EngineAttachSound
@onready var _ignition_sound: AudioStreamPlayer = $IgnitionSound
@onready var _lift_off_sound: AudioStreamPlayer = $LiftOffSound

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_flame.animation_finished.connect(_on_flame_animation_finished)
	_glow_base_scale = _glow.scale
	_visual_base_y = _visual.position.y
	_start_breathing()

func set_ready() -> void:
	if _ready_to_launch:
		return
	_ready_to_launch = true
	_glow.visible = true
	_sparkles.emitting = true

	var fade := create_tween().set_parallel()
	fade.tween_property(_glow, "modulate:a", 1.0, 0.5)
	fade.tween_property(_window_lit, "modulate:a", 1.0, 0.4)

	_glow_tween = create_tween().set_loops()
	_glow_tween.tween_property(_glow, "scale", _glow_base_scale * 1.08, 0.9).set_trans(Tween.TRANS_SINE)
	_glow_tween.tween_property(_glow, "scale", _glow_base_scale, 0.9).set_trans(Tween.TRANS_SINE)

	_idle_tween.kill()
	_visual.scale = Vector2.ONE
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_interval(1.1)
	for angle in EXCITED_ANGLES:
		_idle_tween.tween_property(_visual, "rotation_degrees", angle, 0.08).set_trans(Tween.TRANS_SINE)

func _start_breathing() -> void:
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(_visual, "scale", Vector2(1.015, 0.985), 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.tween_property(_visual, "scale", Vector2(0.99, 1.01), 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if _launching:
		return
	if not _ready_to_launch:
		needs_parts.emit()
		_hop()
		return
	_launch(body)

func _hop() -> void:
	if _hop_tween:
		_hop_tween.kill()
	_visual.position.y = _visual_base_y
	_hop_tween = create_tween()
	for i in 2:
		_hop_tween.tween_property(_visual, "position:y", _visual_base_y - HOP_HEIGHT, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_hop_tween.tween_property(_visual, "position:y", _visual_base_y, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _launch(body: Node2D) -> void:
	_launching = true
	_idle_tween.kill()
	_glow_tween.kill()
	_visual.rotation_degrees = 0.0
	_visual.scale = Vector2.ONE
	_sparkles.emitting = false
	if body.has_method("set_controls_enabled"):
		body.set_controls_enabled(false)
	body.hide()

	var tween := create_tween()
	tween.tween_callback(_door.play.bind(&"close"))
	tween.tween_interval(0.35)
	tween.tween_callback(_on_door_closed)
	tween.tween_interval(0.35)
	tween.tween_callback(_attach_engine)
	tween.tween_interval(0.55)
	tween.tween_callback(_ignite)
	tween.tween_interval(0.7)
	tween.tween_callback(_start_lift_off)
	tween.tween_property(_visual, "scale", Vector2(1.08, 0.92), 0.15)
	tween.tween_property(self, "position:y", position.y - LAUNCH_RISE, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_visual, "scale", Vector2(0.93, 1.12), 0.5)
	tween.tween_callback(func() -> void: launched.emit())

func _on_door_closed() -> void:
	_door_close_sound.play()
	_window_astronaut.show()

func _attach_engine() -> void:
	_engine_attach_sound.play()
	_engine.modulate.a = 0.0
	_engine.position = Vector2(0, 28)
	_engine.show()
	var snap := create_tween().set_parallel()
	snap.tween_property(_engine, "modulate:a", 1.0, 0.1)
	snap.tween_property(_engine, "position:y", 0.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var thunk := create_tween()
	thunk.tween_property(_visual, "scale", Vector2(1.04, 0.96), 0.08)
	thunk.tween_property(_visual, "scale", Vector2.ONE, 0.12)
	_attach_sparks.restart()
	_attach_sparks.emitting = true

func _ignite() -> void:
	_ignition_sound.play()
	_flame.show()
	_flame.play(&"ignite")
	_smoke_burst.restart()
	_smoke_burst.emitting = true
	_rumble(0.7)

func _rumble(duration: float) -> void:
	var rumble := create_tween().set_loops(int(duration / 0.06))
	rumble.tween_property(_visual, "position:x", 1.5, 0.03)
	rumble.tween_property(_visual, "position:x", -1.5, 0.03)
	rumble.finished.connect(func() -> void: _visual.position.x = 0.0)

func _start_lift_off() -> void:
	_lift_off_sound.play()
	_smoke_trail.emitting = true
	create_tween().tween_property(_flame, "scale", Vector2(0.5, 0.75), 0.4)

func _on_flame_animation_finished() -> void:
	if _flame.animation == &"ignite":
		_flame.play(&"burn")
