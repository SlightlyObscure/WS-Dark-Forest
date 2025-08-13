extends Control

static var packedScene: PackedScene = preload("res://ui/views/SettingsScreen.tscn")

func _on_resume_pressed() -> void:
	queue_free()

func _on_settings_pressed() -> void:
	self.visible = false
	var scene: Node = packedScene.instantiate()
	get_node("/root").add_child(scene)

func _on_exit_to_title_screen_pressed() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://ui/views/TitleScreen.tscn")

func _on_exit_to_desktop_pressed() -> void:
	get_tree().quit()
