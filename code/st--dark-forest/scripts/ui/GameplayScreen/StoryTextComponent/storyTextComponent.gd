extends PanelContainer

class_name StoryTextComponent

static var SCENE: PackedScene = preload("res://ui/GameplayScreen/StoryTextComponent.tscn")

var _text: String
var isCurrentElement: bool:
	set(value):
		isCurrentElement = value
		(get_node("Margin/VBoxContainer/ContinueButton") as Button).visible = value

static func create(text: String, isCurrentElement: bool) -> StoryTextComponent:
	var scene: StoryTextComponent = SCENE.instantiate()
	scene._text = text
	(scene.get_node("Margin/VBoxContainer/Text") as Label).text = text
	scene.isCurrentElement = isCurrentElement
	return scene

func _on_continue_button_pressed() -> void:
	SignalRelay.continue_story.emit()
