extends Node

static var menuPackedScene: PackedScene = preload("res://ui/views/MenuScreen.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ToggleMenu"):
		var settingsNode: Control = get_node_or_null("/root/SettingsScreen")
		var menuNode: Control = get_node_or_null("/root/MenuScreen")
		var isOnTitleScreen: bool = get_node_or_null("/root/TitleScreen") != null
		var confirmDeleteSaveDialog: Control = get_node_or_null("/root/ConfirmDeleteSaveDialog")
		
		if settingsNode != null:
			settingsNode.queue_free()
			if menuNode != null:
				menuNode.visible = true
		elif menuNode != null:
			menuNode.queue_free()
		elif confirmDeleteSaveDialog != null:
			confirmDeleteSaveDialog.queue_free()
		elif isOnTitleScreen == false:
			var menu: Node = self.menuPackedScene.instantiate()
			get_node("/root").add_child(menu)
