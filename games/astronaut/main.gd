extends Node2D

func _ready() -> void:
	# Godot can miscompute the fullscreen window's position on multi-monitor
	# setups where a secondary display has a negative-coordinate origin
	# (godotengine/godot#114144). Force it onto the real screen origin.
	var screen := DisplayServer.window_get_current_screen()
	DisplayServer.window_set_position(DisplayServer.screen_get_position(screen), screen)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
