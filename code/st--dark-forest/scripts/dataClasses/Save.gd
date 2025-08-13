extends Node

class_name Save

const _SAVE_DIR_PATH: String = "user://saves"

var fileName: String
var saveName: String
var skills: Dictionary	#<int>
var area: String
var way: String
var shortTermMemory: Array	#<String>
var areaFlags: Dictionary	#<Array<String>>
var currentStoryTextPrefix: String
var currentImage: String
var currentSong: String

@warning_ignore("shadowed_variable")
static func create(saveName: String, skills: Dictionary) -> Save:
	var saveDir: DirAccess = DirAccess.open(_SAVE_DIR_PATH)
	var files: PackedStringArray = saveDir.get_files()
	var lastSaveNum: int = 0
	if files.size() > 0:
		for file: String in files:
			var saveNum: int = int(file.get_slice("save", 1))
			if lastSaveNum < saveNum:
				lastSaveNum = saveNum
	
	var fileName: String = "save" + str(lastSaveNum + 1)
	var save: Save = Save.new(fileName, saveName, skills, "preArea", "-", [], {}, "", "", "")
	
	save.writeSaveFile()
	return save

@warning_ignore("shadowed_variable")
func _init(fileName: String, saveName: String, skills: Dictionary, area: String, way: String, shortTermMemory: Array, areaFlags: Dictionary, currentStoryTextPrefix: String, currentImage: String, currentSong: String) -> void:
	self.fileName = fileName
	self.saveName = saveName
	self.skills = skills
	self.area = area
	self.way = way
	self.shortTermMemory = shortTermMemory
	self.areaFlags = areaFlags
	self.currentStoryTextPrefix = currentStoryTextPrefix
	self.currentImage = currentImage
	self.currentSong = currentSong

static func getSavesFromFiles() -> Array:
	var saveDir: DirAccess = DirAccess.open(_SAVE_DIR_PATH)
	if !saveDir:
		DirAccess.make_dir_absolute(_SAVE_DIR_PATH)
		return []

	var fileNames: PackedStringArray = saveDir.get_files()
	var saves: Array = []
	var saveNums: Array = []
	@warning_ignore("shadowed_variable")
	for fileName: String in fileNames:
		var saveFile: FileAccess = FileAccess.open(_SAVE_DIR_PATH + "/" + fileName, FileAccess.READ)
		var saveJson: Dictionary = JSON.parse_string(saveFile.get_as_text())
		
		var saveName: String = getJsonVal(saveJson, "saveName", null)
		var skills: Dictionary = getJsonVal(saveJson, "skills", null)
		var area: String = getJsonVal(saveJson, "area", "preArea")
		var way: String = getJsonVal(saveJson, "way", "-")
		var shortTermMemory: Array = getJsonVal(saveJson, "shortTermMemory", [])
		var areaFags: Dictionary = getJsonVal(saveJson, "areaFags", {})
		var currentStoryTextPrefix: String = getJsonVal(saveJson, "currentStoryTextPrefix", "")
		var currentImage: String = getJsonVal(saveJson, "currentImage", "")
		var currentSong: String = getJsonVal(saveJson, "currentSong", "")
		
		var save: Save = Save.new(fileName, saveName, skills, area, way, shortTermMemory, areaFags, currentStoryTextPrefix, currentImage, currentSong)
		saves.append(save)
		var saveNum: int = int(fileName.get_slice("save", 1))
		saveNums.append(saveNum)
	var sortedSaves: Array = []
	while saves.size() > 0:
		var nextSaveIndex: int = saveNums.find(saveNums.min())
		sortedSaves.append(saves[nextSaveIndex])
		saves.remove_at(nextSaveIndex)
		saveNums.remove_at(nextSaveIndex)
	return sortedSaves

static func getJsonVal(dict: Dictionary, key: String, default: Variant) -> Variant:
	if dict.has(key):
		return dict[key]
	else:
		return default

func writeSaveFile() -> void:
	var saveFile: FileAccess = FileAccess.open(_SAVE_DIR_PATH + "/" + self.fileName, FileAccess.WRITE)
	
	var jsonString: String = JSON.stringify({
		"saveName": self.saveName,
		"skills": self.skills, 
		"area": self.area,
		"way": self.way,
		"shortTermMemory": self.shortTermMemory,
		"areaFlags": self.areaFlags,
		"currentStoryTextPrefix": self.currentStoryTextPrefix,
		"currentImage": self.currentImage,
		"currentSong": self.currentSong
	})
	
	saveFile.store_line(jsonString)

func deleteSaveFile() -> void:
	var saveDir: DirAccess = DirAccess.open(_SAVE_DIR_PATH)
	saveDir.remove(self.fileName)

func addFlagToCurrentArea(flag: String) -> void:
	if !self.areaFlags.has(self.area):
		self.areaFlags[self.area] = []
	var currentAreaFlags: Array = self.areaFlags[self.area]
	if !currentAreaFlags.has(flag):
		currentAreaFlags.append(flag)

func isFlagSetForCurrentArea(flag: String) -> bool:
	if !self.areaFlags.has(self.area):
		return false
	return (self.areaFlags[self.area] as Array).has(flag)
