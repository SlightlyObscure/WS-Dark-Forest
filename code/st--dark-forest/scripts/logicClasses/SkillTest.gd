extends Node

class_name SkillTest

enum SkillTestDifficulty {
	Simple,
	Moderate,
	Challenging,
	Extreme,
	Impossible
}

const DIFFICULTY_TEXTS: Dictionary = {
	SkillTestDifficulty.Simple: "Simple", 
	SkillTestDifficulty.Moderate: "Moderate", 
	SkillTestDifficulty.Challenging: "Challenging", 
	SkillTestDifficulty.Extreme: "Extreme", 
	SkillTestDifficulty.Impossible: "Impossible"
}

const DIFFICULTY_PERCENTAGES: Array = [100, 70, 30, 10, 0]

static var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

static func getTestDifficulty(skillLevel: int, difficulties: Array) -> SkillTestDifficulty:
	if skillLevel >= difficulties[0]:
		return SkillTestDifficulty.Simple
	elif skillLevel >= difficulties[1]:
		return SkillTestDifficulty.Moderate
	elif skillLevel >= difficulties[2]:
		return SkillTestDifficulty.Challenging
	elif skillLevel >= difficulties[3]:
		return SkillTestDifficulty.Extreme
	return SkillTestDifficulty.Impossible

static func getDifficultyText(skillLevel: int, difficulties: Array) -> String:
	var difficulty: SkillTestDifficulty = SkillTest.getTestDifficulty(skillLevel, difficulties)
	return DIFFICULTY_TEXTS[difficulty]

static func rollTest(skillLevel: int, difficulties: Array) -> bool:
	var difficulty: SkillTestDifficulty = SkillTest.getTestDifficulty(skillLevel, difficulties)
	var diffPercentage: int = DIFFICULTY_PERCENTAGES[difficulty]
	var roll: int = SkillTest._rng.randi_range(1, 100)
	print("Difficulty: " + str(difficulty))
	print("Chance: " + str(diffPercentage) + "%")
	print("Roll: " + str(roll))
	return roll <= diffPercentage
