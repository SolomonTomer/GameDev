extends Node2D

var parts_collected: int = 0
var parts_total: int = 0

@onready var _parts_panel: PartsPanel = $PartsPanel
@onready var _rocket: Rocket = $Rocket

func _ready() -> void:
	var parts := get_tree().get_nodes_in_group("engine_parts")
	parts_total = parts.size()
	for part in parts:
		(part as EnginePart).collected.connect(_on_part_collected)
	_rocket.needs_parts.connect(_on_rocket_needs_parts)
	_rocket.launched.connect(_on_rocket_launched)

func _on_part_collected(part: EnginePart) -> void:
	parts_collected += 1
	_parts_panel.fly_to_next_slot(part.global_position)
	if parts_collected >= parts_total:
		_rocket.set_ready()

func _on_rocket_needs_parts() -> void:
	_parts_panel.pulse_empty_slots()

func _on_rocket_launched() -> void:
	get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
