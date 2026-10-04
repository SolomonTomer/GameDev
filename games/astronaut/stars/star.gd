class_name Star
extends Area2D

signal collected(star: Star)

const BOB_HEIGHT := 5.0
const BOB_TIME := 0.9

@onready var _visual: Sprite2D = $Visual
@onready var _pickup_sound: AudioStreamPlayer = $PickupSound

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var bob := create_tween().set_loops()
	bob.tween_property(_visual, "position:y", -BOB_HEIGHT, BOB_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(_visual, "position:y", BOB_HEIGHT, BOB_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	set_deferred("monitoring", false)
	hide()
	_pickup_sound.play()
	collected.emit(self)
