extends Node

class_name TextFormatter

static func _getStoryPointTestInfo(storyPoint: Dictionary) -> String:
	var test: Dictionary = storyPoint["test"]
	var skill: String = test["skill"]
	var skillLevel: int = UserData.currentSave.skills[skill]
	var testDifficulties: Array = test["difficulties"]
	var difficulty: String = SkillTest.getDifficultyText(skillLevel, testDifficulties)
	var skillTestText: String = "[Skill " + skill + " - " + difficulty + "]"	#TODO: remove Skill
	return "\n" + skillTestText

static func getElaboratedStoryPointText(storyPoint: Dictionary, textPrefix: String) -> String:
	var text: String = textPrefix + storyPoint["text"]
	
	if storyPoint.has("test"):
		text += TextFormatter._getStoryPointTestInfo(storyPoint)
	
	return text

static func getInteractionText(number: int, interaction: Dictionary) -> String:
	var text: String = str(number + 1) + ": " + interaction["text"]
	
	if interaction.has("test"):
		text += TextFormatter._getStoryPointTestInfo(interaction)
	
	return text

static func getWayChosenText(baseText: String, interactionNum: int, interaction: Dictionary) -> String:
	return baseText + "\n\n" + TextFormatter.getInteractionText(interactionNum, interaction)
