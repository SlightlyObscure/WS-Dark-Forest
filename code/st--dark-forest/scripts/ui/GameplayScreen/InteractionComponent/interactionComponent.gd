extends Button

class_name InteractionComponent

static var SCENE: PackedScene = preload("res://ui/GameplayScreen/InteractionComponent.tscn")

var _number: int
var _interaction: Dictionary

static func create(number: int, interaction: Dictionary) -> InteractionComponent:
	var scene: InteractionComponent = SCENE.instantiate()
	scene._number = number
	scene._interaction = interaction
	
	scene.text = TextFormatter.getInteractionText(number, interaction)
	
	return scene

func _pressed() -> void:
	SignalRelay.select_interaction.emit(self._number)
