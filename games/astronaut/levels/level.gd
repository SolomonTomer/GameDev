class_name Level
extends Node2D

signal completed

var _stars_left: int = 0

@onready var _stars: Node2D = $Stars
@onready var _goal: Goal = $Goal

func setup(panel: StarsPanel) -> void:
	var stars := _stars.get_children()
	_stars_left = stars.size()
	panel.show_slots(_stars_left)
	for star in stars:
		(star as Star).collected.connect(_on_star_collected.bind(panel))
	_goal.needs_stars.connect(panel.pulse_empty_slots)
	_goal.completed.connect(completed.emit)

func _on_star_collected(star: Star, panel: StarsPanel) -> void:
	panel.fly_to_next_slot(star.global_position)
	_stars_left -= 1
	if _stars_left == 0:
		_goal.set_ready()
