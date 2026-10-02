class_name Rocket
extends Area2D

signal needs_parts

var _ready_to_launch: bool = false

@onready var _glow: Polygon2D = $Glow

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_glow.visible = false

func set_ready() -> void:
	_ready_to_launch = true
	_glow.visible = true

func _on_body_entered(_body: Node2D) -> void:
	if not _ready_to_launch:
		needs_parts.emit()
