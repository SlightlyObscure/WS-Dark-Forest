@tool
extends "res://scripts/ui/TitleScreen/titleButton.gd"

static var packedScene: PackedScene = preload("res://ui/views/SettingsScreen.tscn")

func _on_button_pressed() -> void:
	super._on_button_pressed()
	var scene: Node = self.packedScene.instantiate()
	get_node("/root").add_child(scene)
