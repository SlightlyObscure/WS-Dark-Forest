extends Control

@onready var _deleteSaveDialogScene: PackedScene = preload("res://ui/SaveSelectScreen/ConfirmDeleteSaveDialog.tscn")
var _saveToBeDeleted: Save

func _ready() -> void:
	var saves: Array = UserData.getSaves()
	for save: Save in saves:
		var saveSlot: SaveSlotComponent = SaveSlotComponent.create(save)
		saveSlot.delete_pressed.connect(_on_delete_save_button_pressed)
		get_node("ScrollContainer/SaveSlots").add_child(saveSlot)

func _on_back_button_pressed() -> void:
	Audio.playSound(Enums.Sound.click)
	get_tree().change_scene_to_file("res://ui/views/TitleScreen.tscn")

func _on_delete_save_button_pressed(save: Save) -> void:
	self._saveToBeDeleted = save
	var deleteConfirmDialog: ConfirmDeleteSaveDialog = self._deleteSaveDialogScene.instantiate()
	deleteConfirmDialog.delete_confirmed.connect(_on_delete_save_confirmed)
	add_sibling(deleteConfirmDialog)

func _on_delete_save_confirmed() -> void:
	UserData.removeSave(self._saveToBeDeleted.fileName)
	self._saveToBeDeleted.deleteSaveFile()
	
	var saveSlots: Array = get_node("ScrollContainer/SaveSlots").get_children()
	for saveSlot: SaveSlotComponent in saveSlots:
		if saveSlot.save.fileName == self._saveToBeDeleted.fileName:
			saveSlot.queue_free()
			break
