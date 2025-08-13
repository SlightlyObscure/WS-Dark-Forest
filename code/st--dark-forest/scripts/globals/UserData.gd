extends Node

var _saves: Array = Save.getSavesFromFiles()
var settings: Settings = Settings.new()
var currentSave: Save = null

func getSaves() -> Array:
	return self._saves

func addSave(save: Save) -> void:
	self._saves.append(save)

func removeSave(saveFileName: String) -> void:
	var deletedSaveIndex: int = self._saves.find_custom(_isSaveToDelete.bind(saveFileName))
	self._saves.remove_at(deletedSaveIndex)

static func _isSaveToDelete(save: Save, nameOfFileToDelete: String) -> bool:
	return save.fileName == nameOfFileToDelete
