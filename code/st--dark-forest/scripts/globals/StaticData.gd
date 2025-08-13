extends Node

var mainCharacterData: Dictionary = {}
var content: Dictionary = {}

func _ready() -> void:
	var mainCharacterFile: FileAccess = FileAccess.open("res://jsons/mainCharacterData.json", FileAccess.READ)
	self.mainCharacterData = JSON.parse_string(mainCharacterFile.get_as_text())
	var contentFile: FileAccess = FileAccess.open("res://jsons/content.json", FileAccess.READ)
	self.content = JSON.parse_string(contentFile.get_as_text())
