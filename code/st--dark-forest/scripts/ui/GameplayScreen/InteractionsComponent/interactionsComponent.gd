extends PanelContainer

class_name InteractionsComponent

static var SCENE: PackedScene = preload("res://ui/GameplayScreen/InteractionsComponent.tscn")

var _text: String
var _interactions: Array
var selectedInteraction: int = -1:
	set(value):
		selectedInteraction = value
		if selectedInteraction != -1:
			(get_node("Margin/VBoxContainer/Interactions") as VBoxContainer).visible = false
			var interaction: Dictionary = self._interactions[value]
			var textLabel: Label = get_node("Margin/VBoxContainer/Text")
			textLabel.text = TextFormatter.getWayChosenText(textLabel.text, selectedInteraction, interaction)

static func create(text: String, interactions: Array) -> InteractionsComponent:
	var scene: InteractionsComponent = SCENE.instantiate()
	scene._text = text
	(scene.get_node("Margin/VBoxContainer/Text") as Label).text = text
	scene._interactions = interactions
	
	var interactionsContainer: Control = scene.get_node("Margin/VBoxContainer/Interactions")
	for index: int in range(interactions.size()):
		var interaction: Dictionary = interactions[index]
		var interactionScene:  = InteractionComponent.create(index, interaction)
		interactionsContainer.add_child(interactionScene)
	
	return scene
