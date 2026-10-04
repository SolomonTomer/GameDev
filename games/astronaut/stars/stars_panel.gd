class_name StarsPanel
extends CanvasLayer

const EMPTY_TEXTURE: Texture2D = preload("res://stars/art/star_slot.svg")
const FILLED_TEXTURE: Texture2D = preload("res://stars/art/star.svg")
const FLY_DURATION := 0.6

@onready var _slots: Array[Node2D] = [$Slot0, $Slot1, $Slot2]
@onready var _slot_fill_sound: AudioStreamPlayer = $SlotFillSound
@onready var _pulse_sound: AudioStreamPlayer = $PulseSound

var _next_slot_index: int = 0
var _flying: Array[Sprite2D] = []

func show_slots(count: int) -> void:
	visible = count > 0
	_next_slot_index = 0
	for icon in _flying:
		icon.queue_free()
	_flying.clear()
	for i in _slots.size():
		_slots[i].visible = i < count
		_slot_sprite(_slots[i]).texture = EMPTY_TEXTURE

func fly_to_next_slot(from_position: Vector2) -> void:
	if _next_slot_index >= _slots.size():
		return
	var slot := _slots[_next_slot_index]
	_next_slot_index += 1

	var icon := Sprite2D.new()
	icon.texture = FILLED_TEXTURE
	icon.scale = Vector2(0.5, 0.5)
	icon.position = from_position
	add_child(icon)
	_flying.append(icon)

	var tween := icon.create_tween()
	tween.set_parallel()
	tween.tween_property(icon, "position", slot.position, FLY_DURATION)
	tween.tween_property(icon, "scale", Vector2(0.75, 0.75), FLY_DURATION)
	tween.chain().tween_callback(func() -> void:
		_slot_sprite(slot).texture = FILLED_TEXTURE
		_flying.erase(icon)
		icon.queue_free()
		_slot_fill_sound.play()
	)

func pulse_empty_slots() -> void:
	if _next_slot_index >= _slots.size():
		return
	_pulse_sound.play()
	for i in range(_next_slot_index, _slots.size()):
		if _slots[i].visible:
			_pulse(_slots[i])

func _slot_sprite(slot: Node2D) -> Sprite2D:
	return slot.get_node("Visual") as Sprite2D

func _pulse(slot: Node2D) -> void:
	var tween := create_tween()
	tween.tween_property(slot, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.15)
