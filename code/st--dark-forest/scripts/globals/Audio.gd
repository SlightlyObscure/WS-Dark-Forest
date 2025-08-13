extends Node

enum TransitionType {
	none,
	instant,
	fade,
	impactFade,
	warp,
	quickWarp
}
const TransitionStringToEnum = {
	"none": TransitionType.none,
	"instant": TransitionType.instant,
	"fade": TransitionType.fade,
	"impactFade": TransitionType.impactFade,
	"warp": TransitionType.warp,
	"quickWarp": TransitionType.quickWarp
}

const SoundStrings = {
	Enums.Sound.click: "click",
	Enums.Sound.click_heavy: "click_heavy",
	Enums.Sound.brush: "brush",
	Enums.Sound.low_chime: "low_chime",
	Enums.Sound.high_chime: "high_chime",
	Enums.Sound.apple_bite: "apple_bite",
}

const NORMAL_SONG_TRANSITION_SPEED = 0.2
const QUICK_SONG_TRANSITION_SPEED = 1
const IMPACT_FADE_THRESHOLD = 0.3

var _soundBusIndex: int = AudioServer.get_bus_index("Sound")
var _musicBusIndex: int = AudioServer.get_bus_index("Music")
var _endingSong: String = ""
var _currentSong: String = ""
var _suspendedSong: String = ""
var _songTransitionType: TransitionType = TransitionType.none
var _songTransitionProgress: float = 0.0	#max 1.0

# create audio player instances
@onready var sounds: Dictionary = {
	"click" : AudioStreamPlayer.new(),
	"click_heavy" : AudioStreamPlayer.new(),
	"brush" : AudioStreamPlayer.new(),
	"low_chime" : AudioStreamPlayer.new(),
	"high_chime" : AudioStreamPlayer.new(),
	"apple_bite" : AudioStreamPlayer.new(),
}

@onready var songs: Dictionary = {
	"ambient_dark": AudioStreamPlayer.new(),
	"dark_service": AudioStreamPlayer.new(),
	"bee": AudioStreamPlayer.new(),
	"lamplight_respite": AudioStreamPlayer.new(),
}

func _ready() -> void:
	var initialMusicVolume: int = UserData.settings.musicVolume
	var initialSoundVolume: int = UserData.settings.soundVolume
	self.setMusicVolume(initialMusicVolume)
	self.setSoundVolume(initialSoundVolume)
	
	for sound: String in sounds.keys():
		sounds[sound].stream = load("res://assets/sounds/" + str(sound) + ".ogg")
		sounds[sound].bus = "Sound"
		add_child(sounds[sound] as AudioStreamPlayer)
	
	for song: String in songs.keys():
		songs[song].stream = load("res://assets/songs/" + str(song) + ".mp3")
		songs[song].bus = "Music"
		add_child(songs[song] as AudioStreamPlayer)

func _process(delta: float) -> void:
	self._doSongTransition(delta)

func _doSongTransition(delta: float) -> void:
	if self._songTransitionType == TransitionType.none:
		return
	
	var transitionSpeed: float
	if self._songTransitionType == TransitionType.quickWarp:
		transitionSpeed = QUICK_SONG_TRANSITION_SPEED
	else:
		transitionSpeed = NORMAL_SONG_TRANSITION_SPEED
	self._songTransitionProgress += transitionSpeed * delta
	if self._songTransitionProgress > 1.0:
		self._songTransitionProgress = 1.0
		
	match self._songTransitionType:
		TransitionType.fade, TransitionType.impactFade:
			if !self._endingSong.is_empty():
				var endingFadeProgress: float = pow(maxf(1.0 - (self._songTransitionProgress * 2), 0), 2)
				(songs[self._endingSong] as AudioStreamPlayer).volume_linear = endingFadeProgress
			var startingFadeProgress: float = pow(maxf((self._songTransitionProgress - 0.5) * 2, 0), 2)
			var currentSongPlayer: AudioStreamPlayer = songs[self._currentSong]
			var songStartThreshold: float = self._getSongStartThreshold(self._songTransitionType)
			if startingFadeProgress > songStartThreshold && !currentSongPlayer.playing:
				currentSongPlayer.play()
			currentSongPlayer.volume_linear = startingFadeProgress
		
		TransitionType.warp, TransitionType.quickWarp:
			if !self._endingSong.is_empty():
				var endingFadeProgress: float = 1.0 - self._songTransitionProgress
				(songs[self._endingSong] as AudioStreamPlayer).volume_linear = endingFadeProgress
			(songs[self._currentSong] as AudioStreamPlayer).volume_linear = self._songTransitionProgress
	
	if self._songTransitionProgress == 1.0:
		self._songTransitionProgress = 0.0
		self._songTransitionType = TransitionType.none
		if !self._endingSong.is_empty():
			(songs[self._endingSong] as AudioStreamPlayer).stop()
			self._endingSong = ""

func _getSongStartThreshold(transitionType: TransitionType) -> float:
	if transitionType == TransitionType.impactFade:
		return IMPACT_FADE_THRESHOLD
	else:
		return 0

func isCurrentSongQuiet() -> bool:
	return self._currentSong == "ambient_dark"

func setMusicVolume(volume: float) -> void:
	var musicPercentage: float = volume / 100
	AudioServer.set_bus_volume_db(self._musicBusIndex, linear_to_db(musicPercentage))

func setSoundVolume(volume: float) -> void:
	var soundPercentage: float = volume / 100
	AudioServer.set_bus_volume_db(self._soundBusIndex, linear_to_db(soundPercentage))

func playSound(sound : Enums.Sound) -> void:
	var soundString: String = SoundStrings[sound]
	(sounds[soundString] as AudioStreamPlayer).play()

func playSoundByString(sound: String) -> void:
	(sounds[sound] as AudioStreamPlayer).play()

func playSong(nextSong: String, transitionString: String) -> void:
	if self._currentSong == nextSong:
		return
	
	self._songTransitionProgress = 0.0
	
	if self._endingSong != "":
		(songs[self._endingSong] as AudioStreamPlayer).volume_linear = 0
	
	var transition: TransitionType = TransitionStringToEnum[transitionString]
	self._songTransitionType = transition
	match transition:
		TransitionType.instant:
			if !self._currentSong.is_empty():
				(songs[self._currentSong] as AudioStreamPlayer).stop()
			(songs[nextSong] as AudioStreamPlayer).volume_linear = 1.0	#just in case
			(songs[nextSong] as AudioStreamPlayer).play()
			self._currentSong = nextSong
		TransitionType.fade, TransitionType.impactFade:
			(songs[nextSong] as AudioStreamPlayer).volume_linear = 0
			self._endingSong = self._currentSong
			self._currentSong = nextSong
		TransitionType.warp, TransitionType.quickWarp:
			var currentSongPosition: float = (songs[self._currentSong] as AudioStreamPlayer).get_playback_position()
			(songs[nextSong] as AudioStreamPlayer).volume_linear = 0
			(songs[nextSong] as AudioStreamPlayer).play(currentSongPosition)
			self._endingSong = self._currentSong
			self._currentSong = nextSong

func startPlayingMusicSample() -> void:
	self._songTransitionType = TransitionType.quickWarp
	
	if self._endingSong == "dark_service":
		self._songTransitionProgress = 1 - self._songTransitionProgress
		self._endingSong = self._currentSong
		self._suspendedSong = self._currentSong
		self._currentSong = "dark_service"
	else:
		self._songTransitionProgress = 0.0
		self._endingSong = self._currentSong
		self._suspendedSong = self._currentSong
		self._currentSong = "dark_service"
		(songs[self._currentSong] as AudioStreamPlayer).volume_linear = 0
		(songs[self._currentSong] as AudioStreamPlayer).play(18)

func stopPlayingMusicSample() -> void:
	self._songTransitionProgress = 0.0
	self._endingSong = self._currentSong
	self._currentSong = self._suspendedSong
	(songs[self._currentSong] as AudioStreamPlayer).volume_linear = 0
	(songs[self._currentSong] as AudioStreamPlayer).play()
	self._songTransitionType = TransitionType.warp
