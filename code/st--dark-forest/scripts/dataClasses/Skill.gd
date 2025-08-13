extends Node

class_name Skill

var displayName: String
var description: String
var min: int
var max: int
var level: int

static func fromDict(dict: Dictionary) -> Skill:
	var skill: Skill = Skill.new()
	skill.displayName = dict["displayName"]
	skill.description = dict["description"]
	skill.min = dict["min"]
	skill.max = dict["max"]
	
	if dict.has("level"):
		skill.level = dict["level"]
	return skill
