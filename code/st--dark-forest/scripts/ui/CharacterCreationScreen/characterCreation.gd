extends Node

class_name CharacterCreationScreenController

var _skillPoints: int:
	set(value):
		_skillPoints = value
		(get_node("SkillPointsDisplay/Value") as Label).text = str(value)
var skills: Dictionary

func _ready() -> void:
	self._skillPoints = StaticData.mainCharacterData["skillPoints"]
	self.skills = (StaticData.mainCharacterData["skills"] as Dictionary).duplicate(true)
	for skillName: String in self.skills:
		var skill: Skill = Skill.fromDict(self.skills[skillName] as Dictionary)
		skill.level = skill.min
		self.skills[skillName] = skill
	self._updateSkillLevelDisplays()

func _process(_delta: float) -> void:
	var saveFileNameInput: LineEdit = self.get_node("SaveFileNameInput")
	var createSaveButton: Button = self.get_node("Begin")
	if self._skillPoints == 0 && saveFileNameInput.text != "":
		createSaveButton.disabled = false
	else:
		createSaveButton.disabled = true

func _updateSkillLevelDisplays() -> void:
	for skillName: String in self.skills:
		var label: Label = get_node("Skills/Skill" + skillName + "/SkillLevel")
		var skill: Skill = self.skills[skillName]
		label.text = str(int(skill.level)) + "/" + str(int(skill.max))
		var isClickableBorder: TextureRect = get_node("Skills/Skill" + skillName + "/CenterContainer/IsClickableBorder")
		if self._skillPoints == 0 || skill.level == skill.max:
			isClickableBorder.visible = false
		else:
			isClickableBorder.visible = true

func _increaseSkillLevel(skillName: String) -> void:
	var skill: Skill = self.skills[skillName]
	if self._skillPoints > 0 && skill.level < skill.max:
		self._skillPoints -= 1
		skill.level += 1
		self._updateSkillLevelDisplays()
		Audio.playSound(Enums.Sound.high_chime)

func _decreaseSkillLevel(skillName: String) -> void:
	var skill: Skill = self.skills[skillName]
	if skill.level > skill.min:
		self._skillPoints += 1
		skill.level -= 1
		self._updateSkillLevelDisplays()
		Audio.playSound(Enums.Sound.low_chime)

func _handle_skill_icon_input(event: InputEvent, skillName: String) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).pressed:
			if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
				self._increaseSkillLevel(skillName)
			elif (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
				self._decreaseSkillLevel(skillName)

func _on_skill_a_icon_input(event: InputEvent) -> void:
	self._handle_skill_icon_input(event, "A")

func _on_skill_b_icon_input(event: InputEvent) -> void:
	self._handle_skill_icon_input(event, "B")
