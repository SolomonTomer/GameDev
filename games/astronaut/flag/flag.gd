class_name Flag
extends Goal

const CELEBRATE_TIME := 2.0
const CELEBRATE_WAVE_SPEED := 2.5

@export var awake_at_start: bool = false

var _awake: bool = false
var _finished: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _sparkles: CPUParticles2D = $Sparkles
@onready var _raise_sound: AudioStreamPlayer = $RaiseSound
@onready var _complete_sound: AudioStreamPlayer = $CompleteSound

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if awake_at_start:
		_awake = true
		_sprite.play(&"wave")
	else:
		_sprite.play(&"off")

func set_ready() -> void:
	if _awake:
		return
	_awake = true
	_sprite.play(&"wave")
	_raise_sound.play()
	_sparkles.restart()
	var pop := create_tween()
	pop.tween_property(_sprite, "scale", Vector2(2.4, 1.7), 0.1)
	pop.tween_property(_sprite, "scale", Vector2(1.8, 2.2), 0.12)
	pop.tween_property(_sprite, "scale", Vector2(2, 2), 0.12)

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	if _finished:
		return
	if not _awake:
		needs_stars.emit()
		return
	_finished = true
	if body.has_method("celebrate"):
		body.celebrate()
	_sprite.speed_scale = CELEBRATE_WAVE_SPEED
	_complete_sound.play()
	_sparkles.restart()
	var tween := create_tween()
	tween.tween_interval(CELEBRATE_TIME)
	tween.tween_callback(completed.emit)
