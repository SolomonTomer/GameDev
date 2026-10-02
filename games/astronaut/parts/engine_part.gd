class_name EnginePart
extends Area2D

signal collected(part: EnginePart)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	set_deferred("monitoring", false)
	hide()
	collected.emit(self)
