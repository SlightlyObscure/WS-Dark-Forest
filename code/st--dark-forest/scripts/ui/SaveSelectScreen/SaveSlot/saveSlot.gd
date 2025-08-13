extends PanelContainer

class_name SaveSlotComponent

const UNSELECTED_COLOR: Color = Color("#2a2a2a")
const SELECTED_COLOR: Color = Color("#343434")

static var SCENE: PackedScene = preload("res://ui/SaveSelectScreen/SaveSlot.tscn")
var save: Save

signal delete_pressed(save: Save)

@warning_ignore("shadowed_variable")
static func create(save: Save) -> SaveSlotComponent:
	var scene: SaveSlotComponent = SCENE.instantiate()
	scene.save = save
	return scene

func _ready() -> void:
	(get_node("Margin/HBoxContainer/Text/SaveName") as Label).text = self.save.saveName
	var area: String = self.save.area
	var areaDisplayText: String = StaticData.content[area]["areaDisplayName"]
	(get_node("Margin/HBoxContainer/Text/SublineMargin/Subline/Location") as Label).text = areaDisplayText

func _on_mouse_entered() -> void:
	(get_theme_stylebox("panel") as StyleBoxFlat).bg_color = SELECTED_COLOR
	Audio.playSound(Enums.Sound.brush)

func _on_delete_save_button_mouse_entered() -> void:
	(get_theme_stylebox("panel") as StyleBoxFlat).bg_color = SELECTED_COLOR

func _on_mouse_exited() -> void:
	(get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UNSELECTED_COLOR

func _on_delete_save_button_mouse_exited() -> void:
	(get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UNSELECTED_COLOR

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			if (event as InputEventMouseButton).pressed:
				UserData.currentSave = self.save
				Audio.playSound(Enums.Sound.click_heavy)
				get_tree().change_scene_to_file("res://ui/views/GameplayScreen.tscn")

func _on_delete_save_pressed() -> void:
	self.delete_pressed.emit(self.save)
	Audio.playSound(Enums.Sound.click)
