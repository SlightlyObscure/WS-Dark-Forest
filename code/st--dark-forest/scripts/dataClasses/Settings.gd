extends Node

class_name Settings

const _SETTINGS_PATH: String = "user://settings.cfg"

var _settingsFile: ConfigFile = ConfigFile.new()

var isFullscreen: bool:
	set(value):
		isFullscreen = value
		self._settingsFile.set_value("settings", "is_fullscreen", isFullscreen)
		self._settingsFile.save(_SETTINGS_PATH)
		if isFullscreen == true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

var resolution: int:
	set(value):
		resolution = value
		self._settingsFile.set_value("settings", "resolution", resolution)
		self._settingsFile.save(_SETTINGS_PATH)

var musicVolume: int:
	set(value):
		musicVolume = value
		self._settingsFile.set_value("settings", "music_volume", musicVolume)
		self._settingsFile.save(_SETTINGS_PATH)

var soundVolume: int:
	set(value):
		soundVolume = value
		self._settingsFile.set_value("settings", "sound_volume", soundVolume)
		self._settingsFile.save(_SETTINGS_PATH)


func _init() -> void:
	self._settingsFile.load(_SETTINGS_PATH)
	
	self.isFullscreen = self._settingsFile.get_value("settings", "is_fullscreen", false)
	self.resolution = self._settingsFile.get_value("settings", "resolution", 1)
	self.musicVolume = self._settingsFile.get_value("settings", "music_volume", 50)
	self.soundVolume = self._settingsFile.get_value("settings", "sound_volume", 50)
