extends Node2D

const FADE_TIME := 0.35

@export var levels: Array[PackedScene] = []

var _index: int = 0
var _level: Level

@onready var _stars_panel: StarsPanel = $StarsPanel
@onready var _fade: ColorRect = $Fade/Rect

func _ready() -> void:
	_load_level(0)

func _load_level(index: int) -> void:
	if _level:
		remove_child(_level)
		_level.queue_free()
	_index = index
	_level = levels[_index].instantiate() as Level
	add_child(_level)
	_level.setup(_stars_panel)
	_level.completed.connect(_on_level_completed)

func _on_level_completed() -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, FADE_TIME)
	tween.tween_callback(func() -> void: _load_level((_index + 1) % levels.size()))
	tween.tween_property(_fade, "modulate:a", 0.0, FADE_TIME)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
