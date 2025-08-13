extends Node

const MUSIC_SAMPLE_PLAY_DURATION: int = 5		#seconds

var _fullScreenOption: bool
var _resolutionOption: int
var _musicOption: int:
	set(value):
		_musicOption = value
		(get_node("DialogPanel/MarginContainer/Options/MusicVolumeRow/Percentage") as Label).text = str(self._musicOption) + "%"
var _soundOption: int:
	set(value):
		_soundOption = value
		(get_node("DialogPanel/MarginContainer/Options/SoundVolumeRow/Percentage") as Label).text = str(self._soundOption) + "%"
var _musicSampleStarted: float = 0


func _ready() -> void:
	self._fullScreenOption = UserData.settings.isFullscreen
	self._resolutionOption = UserData.settings.resolution
	self._musicOption = UserData.settings.musicVolume
	self._soundOption = UserData.settings.soundVolume
	
	(get_node("DialogPanel/MarginContainer/Options/FullscreenRow/CheckBox") as CheckBox).set_pressed_no_signal(self._fullScreenOption)
	(get_node("DialogPanel/MarginContainer/Options/MusicVolumeRow/HSlider") as HSlider).set_value_no_signal(self._musicOption)
	(get_node("DialogPanel/MarginContainer/Options/SoundVolumeRow/HSlider") as HSlider).set_value_no_signal(self._soundOption)

func _process(delta: float) -> void:
	if self._musicSampleStarted > 0:
		var currentTime: float = Time.get_unix_time_from_system()
		if currentTime - self._musicSampleStarted > MUSIC_SAMPLE_PLAY_DURATION:
			self._musicSampleStarted = 0
			Audio.stopPlayingMusicSample()

func _on_fullscreen_option_pressed(value: bool) -> void:
	self._fullScreenOption = value
	UserData.settings.isFullscreen = value

func _on_music_volume_changed(value: int) -> void:
	self._musicOption = value
	Audio.setMusicVolume(value)
	if Audio.isCurrentSongQuiet():
		Audio.startPlayingMusicSample()
		self._musicSampleStarted = Time.get_unix_time_from_system()

func _on_music_volume_drag_ended(_value_changed: bool) -> void:
	UserData.settings.musicVolume = self._musicOption

func _on_sound_volume_changed(value: int) -> void:
	self._soundOption = value
	Audio.setSoundVolume(value)

func _on_sound_volume_drag_ended(_value_changed: bool) -> void:
	Audio.playSound(Enums.Sound.click_heavy)
	UserData.settings.soundVolume = self._soundOption

func _on_close_window_pressed() -> void:
	Audio.playSound(Enums.Sound.click)
	queue_free()
