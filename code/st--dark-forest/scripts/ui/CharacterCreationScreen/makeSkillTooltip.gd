extends Control

@export var _skillName: String

var _isTooltipVisible: bool = false

func _ready() -> void:
	var scriptNode: Control = self
	scriptNode.mouse_entered.connect(_on_mouse_entered)
	scriptNode.mouse_exited.connect(_on_mouse_exited)
	
	var tooltip: PanelContainer = preload("res://ui/CharacterCreationScreen/SkillTooltip.tscn").instantiate()
	tooltip.visible = false
	var skill: Dictionary = StaticData.mainCharacterData["skills"][self._skillName]
	(tooltip.get_node("MarginContainer/VBoxContainer/SkillName") as Label).text = skill.displayName
	(tooltip.get_node("MarginContainer/VBoxContainer/SkillDescription") as Label).text = skill.description
	self.add_child(tooltip)

func _process(_delta: float) -> void:
	if self._isTooltipVisible:
		var tooltip: PanelContainer = self.get_node("SkillTooltip")
		var mousePosition: Vector2 = self.get_viewport().get_mouse_position()
		tooltip.position = mousePosition - self.get_global_rect().position + Vector2(10, 0)

func _on_mouse_entered() -> void:
	var scriptNode: Control = self.get_node("SkillTooltip")
	scriptNode.visible = true
	self._isTooltipVisible = true

func _on_mouse_exited() -> void:
	var scriptNode: Control = self.get_node("SkillTooltip")
	scriptNode.visible = false
	self._isTooltipVisible = false
