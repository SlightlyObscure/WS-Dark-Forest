@tool
extends "res://scripts/ui/TitleScreen/titleButton.gd"

func _on_button_pressed() -> void:
	super._on_button_pressed()
	get_tree().change_scene_to_file("res://ui/views/SaveSelectScreen.tscn")
