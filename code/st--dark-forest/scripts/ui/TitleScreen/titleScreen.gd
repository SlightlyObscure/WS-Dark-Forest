extends Node

func _ready() -> void:
	if UserData.getSaves().size() == 0:
		(get_node("Buttons/Continue") as TitleButtonComponent).disabled = true
	
	Audio.playSong("ambient_dark", "fade")
