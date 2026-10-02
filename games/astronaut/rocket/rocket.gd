class_name Rocket
extends Area2D

signal needs_parts
signal launched

const LAUNCH_RISE := 1400.0
const DOOR_CLOSED_COLOR := Color(0.7, 0.72, 0.75, 1)

var _ready_to_launch: bool = false
var _launching: bool = false

@onready var _glow: Polygon2D = $Glow
@onready var _door: Polygon2D = $Door
@onready var _engine: Polygon2D = $Engine
@onready var _flame: CPUParticles2D = $Flame
@onready var _door_close_sound: AudioStreamPlayer = $DoorCloseSound
@onready var _engine_attach_sound: AudioStreamPlayer = $EngineAttachSound
@onready var _ignition_sound: AudioStreamPlayer = $IgnitionSound
@onready var _lift_off_sound: AudioStreamPlayer = $LiftOffSound

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_glow.visible = false
	_engine.visible = false
	_flame.emitting = false

func set_ready() -> void:
	_ready_to_launch = true
	_glow.visible = true

func _on_body_entered(body: Node2D) -> void:
	if _launching:
		return
	if not _ready_to_launch:
		needs_parts.emit()
		return
	_launch(body)

func _launch(body: Node2D) -> void:
	_launching = true
	if body.has_method("set_controls_enabled"):
		body.set_controls_enabled(false)
	body.hide()

	var tween := create_tween()
	tween.tween_property(_door, "color", DOOR_CLOSED_COLOR, 0.4)
	tween.tween_callback(_door_close_sound.play)
	tween.tween_interval(0.3)
	tween.tween_callback(func() -> void:
		_engine.visible = true
		_engine_attach_sound.play()
	)
	tween.tween_interval(0.4)
	tween.tween_callback(func() -> void:
		_flame.emitting = true
		_ignition_sound.play()
	)
	tween.tween_interval(0.5)
	tween.tween_callback(_lift_off_sound.play)
	tween.tween_property(self, "position:y", position.y - LAUNCH_RISE, 1.5)
	tween.tween_callback(func() -> void: launched.emit())
