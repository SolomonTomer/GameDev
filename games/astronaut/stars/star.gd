class_name Star
extends Area2D

signal collected(star: Star)

@onready var _pickup_sound: AudioStreamPlayer = $PickupSound

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	set_deferred("monitoring", false)
	hide()
	_pickup_sound.play()
	collected.emit(self)
