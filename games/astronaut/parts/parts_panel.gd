class_name PartsPanel
extends CanvasLayer

const SLOT_COLOR_FILLED := Color(1, 0.85, 0.2, 1)
const FLY_DURATION := 0.6

@onready var _slots: Array[Polygon2D] = [
	$Slot0/Visual,
	$Slot1/Visual,
	$Slot2/Visual,
]
@onready var _slot_fill_sound: AudioStreamPlayer = $SlotFillSound
@onready var _pulse_sound: AudioStreamPlayer = $PulseSound

var _next_slot_index: int = 0

func fly_to_next_slot(from_position: Vector2) -> void:
	if _next_slot_index >= _slots.size():
		return
	var slot := _slots[_next_slot_index]
	_next_slot_index += 1

	var icon := Polygon2D.new()
	icon.polygon = slot.polygon
	icon.color = SLOT_COLOR_FILLED
	icon.position = from_position
	add_child(icon)

	var tween := create_tween()
	tween.tween_property(icon, "position", slot.global_position, FLY_DURATION)
	tween.tween_callback(func() -> void:
		slot.color = SLOT_COLOR_FILLED
		icon.queue_free()
		_slot_fill_sound.play()
	)

func pulse_empty_slots() -> void:
	if _next_slot_index >= _slots.size():
		return
	_pulse_sound.play()
	for i in range(_next_slot_index, _slots.size()):
		_pulse(_slots[i])

func _pulse(slot: Polygon2D) -> void:
	var tween := create_tween()
	tween.tween_property(slot, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.15)
