class_name StarsPanel
extends CanvasLayer

const SLOT_COLOR_EMPTY := Color(0.3, 0.3, 0.35, 1)
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
var _flying: Array[Polygon2D] = []

func show_slots(count: int) -> void:
	visible = count > 0
	_next_slot_index = 0
	for icon in _flying:
		icon.queue_free()
	_flying.clear()
	for i in _slots.size():
		_slots[i].get_parent().visible = i < count
		_slots[i].color = SLOT_COLOR_EMPTY

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
	_flying.append(icon)

	var tween := icon.create_tween()
	tween.tween_property(icon, "position", slot.global_position, FLY_DURATION)
	tween.tween_callback(func() -> void:
		slot.color = SLOT_COLOR_FILLED
		_flying.erase(icon)
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
