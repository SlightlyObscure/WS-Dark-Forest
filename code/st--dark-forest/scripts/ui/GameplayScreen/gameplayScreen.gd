extends Control

const SCENE_IMAGE_FOLDER_PATH: String = "res://assets/gameplayScenes/"
const TEST_RESULT_SUCCESS: String = "[Success] "
const TEST_RESULT_FAILURE: String = "[Failure] "
var SCENE_IMAGES: Dictionary = {}

var _registeredProcessInvocations: Array = []

var _currentTextPrefix: String = ""
var _currentText: String = ""
var _gainFlag: String = ""
var _goTo: String = ""
var _travelTo: String = ""
var _test: Dictionary = {}
var _interactions: Array = []

func _ready() -> void:
	SignalRelay.continue_story.connect(_on_continue_story)
	SignalRelay.select_interaction.connect(_on_select_interaction)
	
	for fileName: String in DirAccess.get_files_at(self.SCENE_IMAGE_FOLDER_PATH):
		if (fileName.get_extension() == "import"):
			fileName = fileName.replace('.import', '')
			var fileNameWithoutExtension: String = fileName.split(".")[0]
			self.SCENE_IMAGES[fileNameWithoutExtension] = ResourceLoader.load(self.SCENE_IMAGE_FOLDER_PATH + fileName)
	
	var area: String = UserData.currentSave.area
	self._setAreaText(StaticData.content[area]["areaDisplayName"] as String)
	
	self._currentTextPrefix = UserData.currentSave.currentStoryTextPrefix
	if UserData.currentSave.currentImage != "":
		self._setImage(UserData.currentSave.currentImage)
	if UserData.currentSave.currentSong != "":
		self._playSong(UserData.currentSave.currentSong, "instant")
	
	var storyElementsContainer: Control = get_node("%StoryElements")
	var storyLog: Array = []
	if UserData.currentSave.shortTermMemory.size() > 0:
		for memory: String in UserData.currentSave.shortTermMemory:
			storyLog.append(StoryTextComponent.create(memory, false))
		
		for storyElement: PanelContainer in storyLog:
			storyElementsContainer.add_child(storyElement)
	
	self._manifestNextStoryElement()

func _process(delta: float) -> void:
	for process: Callable in self._registeredProcessInvocations:
		process.call(delta)
	
	if Input.is_action_just_pressed("Continue"):
		self._on_continue_story()
	
	if Input.is_action_just_pressed("SelectOption1"):
		self._on_select_interaction(0)
	elif Input.is_action_just_pressed("SelectOption2"):
		self._on_select_interaction(1)
	elif Input.is_action_just_pressed("SelectOption3"):
		self._on_select_interaction(2)
	elif Input.is_action_just_pressed("SelectOption4"):
		self._on_select_interaction(3)
	elif Input.is_action_just_pressed("SelectOption5"):
		self._on_select_interaction(4)
	elif Input.is_action_just_pressed("SelectOption6"):
		self._on_select_interaction(5)
	elif Input.is_action_just_pressed("SelectOption7"):
		self._on_select_interaction(6)
	elif Input.is_action_just_pressed("SelectOption8"):
		self._on_select_interaction(7)
	elif Input.is_action_just_pressed("SelectOption9"):
		self._on_select_interaction(8)
	
	if Input.is_action_just_pressed("DebugKey"):
		self._debugDumpData()


func _debugDumpData() -> void:
	print("------------------------------------------")
	print("SAVE DATA")
	print("Save: " + UserData.currentSave.saveName)
	print("Skills: ")
	for skill: String in UserData.currentSave.skills:
		print("  " + skill + ": " + str(UserData.currentSave.skills[skill]))
	print("Area: " + UserData.currentSave.area)
	print("Way: " + UserData.currentSave.way)
	print("Area Flags:")
	for area: String in UserData.currentSave.areaFlags:
		print("  " + area + ": " + str(UserData.currentSave.areaFlags[area]))
	print("Short Term Memory: [")
	for memory: String in UserData.currentSave.shortTermMemory:
		print("  \"" + memory + "\"")
	print("]")
	print("------------------------------------------")
	print("LOCAL DATA")
	print("Current Text Prefix: " + self._currentTextPrefix)
	print("Current Text: " + self._currentText)
	print("Go To: " + self._goTo)
	print("Travel To: " + self._travelTo)
	print("Test: " + str(self._test))
	print("Interactions: " + str(self._interactions))
	print("------------------------------------------")

func _setAreaText(areaText: String) -> void:
	var label: Label = get_node("HBoxContainer/MainArea/BottomRow/AreaPanel/Margin/AreaText")
	label.text = areaText

func _setImage(imageName: String) -> void:
	var sceneImage: TextureRect = get_node("%SceneImage")
	sceneImage.texture = self.SCENE_IMAGES[imageName] as CompressedTexture2D

func _playSong(songName: String, songTransition: Variant) -> void:
	print("PLAY SONG: " + songName)
	var checkedTransition: String
	if typeof(songTransition) == TYPE_STRING: 
		checkedTransition = songTransition
	else:
		checkedTransition = "fade"
	Audio.playSong(songName, checkedTransition)

func _playSound(soundName: String) -> void:
	print("PLAY SOUND: " + soundName)
	Audio.playSoundByString(soundName)

func _clearStoryText() -> void:
	var storyElementsContainer: Control = get_node("%StoryElements")
	for storyElement in storyElementsContainer.get_children():
		storyElement.queue_free()

func _manifestNextStoryElement() -> void:
	var storyPoint: Dictionary
	if UserData.currentSave.way == "-":
		storyPoint = StaticData.content[UserData.currentSave.area]
		self._setAreaText(storyPoint["areaDisplayName"] as String)
	else:
		storyPoint = StaticData.content[UserData.currentSave.area]["ways"][UserData.currentSave.way]
	
	var shouldSave: bool = false
	if storyPoint.has("image"):
		self._setImage(storyPoint["image"] as String)
		UserData.currentSave.currentImage = storyPoint["image"]
		shouldSave = true
	if storyPoint.has("song"):
		var songTransition: Variant
		if storyPoint.has("songTransition"):
			songTransition = storyPoint["songTransition"]
		self._playSong(storyPoint["song"] as String, songTransition)
		UserData.currentSave.currentSong = storyPoint["song"]
		shouldSave = true
	if shouldSave:
		UserData.currentSave.writeSaveFile()
	
	if storyPoint.has("sound"):
		self._playSound(storyPoint["sound"] as String)
	
	if storyPoint.has("invocation"):
		(self[storyPoint["invocation"] as String] as Callable).call()
	
	self._currentText = TextFormatter.getElaboratedStoryPointText(storyPoint, self._currentTextPrefix)
	
	if storyPoint.has("gainFlag"):
		self._gainFlag = storyPoint["gainFlag"]
	
	var storyElementToAdd: Node
	if storyPoint.has("interactions"):
		var allInteractions: Array = storyPoint["interactions"]
		self._interactions = allInteractions.filter(_isInteractionAvailable)
		storyElementToAdd = InteractionsComponent.create(self._currentText, self._interactions)
	else:
		if storyPoint.has("goTo"):
			self._goTo = storyPoint["goTo"]
		elif storyPoint.has("travelTo"):
			self._travelTo = storyPoint["travelTo"]
		elif storyPoint.has("test"):
			self._test = storyPoint["test"]
		var hasContinuation: bool = storyPoint.has("ending") == false
		storyElementToAdd = StoryTextComponent.create(self._currentText, hasContinuation)
	
	var storyElementsContainer: Control = get_node("%StoryElements")
	storyElementsContainer.add_child(storyElementToAdd)
	var storyScrollContainer: ScrollContainer = get_node("%StoryScrollContainer")
	await storyScrollContainer.sort_children
	storyScrollContainer.scroll_vertical = storyScrollContainer.get_v_scroll_bar().max_value

static func _isInteractionAvailable(interaction: Dictionary) -> bool:
	if (!interaction.has("revealedBy") && !interaction.has("obscuredBy")):
		return true
	if (interaction.has("revealedBy")):
		return UserData.currentSave.isFlagSetForCurrentArea(interaction["revealedBy"] as String)
	else:	#TODO explicit elif and exception?
		return !(UserData.currentSave.isFlagSetForCurrentArea(interaction["obscuredBy"] as String))

func _clearStoryPoint() -> void:
	self._currentText = ""
	self._gainFlag = ""
	self._goTo = ""
	self._travelTo = ""
	self._test = {}
	self._interactions = []

func _processContinuation() -> void:
	self._currentTextPrefix = ""
	UserData.currentSave.currentStoryTextPrefix = ""
	
	if self._goTo == "-":
		UserData.currentSave.shortTermMemory = []
		UserData.currentSave.way = "-" 
		self._clearStoryText()
	elif self._goTo != "":
		UserData.currentSave.shortTermMemory.append(self._currentText)
		UserData.currentSave.way = self._goTo
	elif self._travelTo != "":
		UserData.currentSave.shortTermMemory = []
		UserData.currentSave.area = self._travelTo
		UserData.currentSave.way = "-"
		self._clearStoryText()
	elif !self._test.is_empty():  #TODO explicit elif and exception?
		UserData.currentSave.shortTermMemory.append(self._currentText)
		var skillLevel: int = UserData.currentSave.skills[self._test["skill"]]
		var difficulties: Array = self._test["difficulties"]
		var testPassed: bool = SkillTest.rollTest(skillLevel, difficulties)
		
		if testPassed:
			UserData.currentSave.way = self._test["pass"]
			self._currentTextPrefix = TEST_RESULT_SUCCESS
			UserData.currentSave.currentStoryTextPrefix = TEST_RESULT_SUCCESS
		else:
			#TODO: use strain
			UserData.currentSave.way = self._test["fail"]
			self._currentTextPrefix = TEST_RESULT_FAILURE
			UserData.currentSave.currentStoryTextPrefix = TEST_RESULT_FAILURE
	
	UserData.currentSave.addFlagToCurrentArea(self._gainFlag)
	UserData.currentSave.writeSaveFile()
	self._clearStoryPoint()
	self._manifestNextStoryElement()

func _on_continue_story() -> void:
	if self._goTo == "" && self._travelTo == "" && self._test.is_empty():
		return
	
	Audio.playSound(Enums.Sound.click)
	
	var storyElementsContainer: Control = get_node("%StoryElements")
	var lastChildIndex: int = storyElementsContainer.get_child_count() - 1
	var lastStoryElement: StoryTextComponent = storyElementsContainer.get_child(lastChildIndex)
	lastStoryElement.isCurrentElement = false
	
	self._processContinuation()

func _on_select_interaction(interactionNum: int) -> void:
	if self._interactions.size() <= interactionNum:
		return
	
	Audio.playSound(Enums.Sound.click_heavy)
	
	var storyElementsContainer: Control = get_node("%StoryElements")
	var lastChildIndex: int = storyElementsContainer.get_child_count() - 1
	var lastStoryElement: InteractionsComponent = storyElementsContainer.get_child(lastChildIndex)
	lastStoryElement.selectedInteraction = interactionNum
	
	var interaction: Dictionary = self._interactions[interactionNum]
	var chosenWayText: String = TextFormatter.getWayChosenText(self._currentText, interactionNum, interaction)
	self._currentText = chosenWayText
	if interaction.has("gainFlag"):
		self._gainFlag = interaction["gainFlag"]
	if interaction.has("goTo"):
		self._goTo = interaction["goTo"]
	if interaction.has("travelTo"):
		self._travelTo = interaction["travelTo"]
	if interaction.has("test"):
		self._test = interaction["test"]
		
	self._processContinuation()


func imagineBeeFunc() -> void:
	var beeTexture: CompressedTexture2D = ResourceLoader.load("res://assets/images/bee_image.png")
	var beeImage: TextureRect = TextureRect.new()
	beeImage.name = "BeeImage"
	beeImage.texture = beeTexture
	beeImage.custom_minimum_size = Vector2(660, 660)
	beeImage.pivot_offset = Vector2(330, 330)
	beeImage.expand_mode = TextureRect.ExpandMode.EXPAND_FIT_HEIGHT
	beeImage.modulate.a = 0
	get_node("%SceneImageWrapper").add_child(beeImage)
	self._registeredProcessInvocations.append(self.imagineBeeProcessFunc)
	print("IMAGINE BEE FUNC")

func imagineBeeProcessFunc(delta: float) -> void:
	var beeImage: TextureRect = get_node("%SceneImageWrapper/BeeImage")
	if beeImage.modulate.a < 1:
		beeImage.modulate.a += 0.02 * delta
	beeImage.rotation += 2 * delta
