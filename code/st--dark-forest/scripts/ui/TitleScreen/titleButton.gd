@tool
extends Control

class_name TitleButtonComponent

@export var text: String:
	get:
		return text
	set(value):
		text = value
		(get_node("Button") as Button).text = value
@export var disabled: bool:
	get:
		return disabled
	set(value):
		disabled = value
		(get_node("Button") as Button).disabled = value

# implement in derived script to give button a function
func _on_button_pressed() -> void:
	Audio.playSound(Enums.Sound.click)
