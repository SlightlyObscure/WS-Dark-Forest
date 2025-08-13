extends Button

func _pressed() -> void:
	Audio.playSound(Enums.Sound.click)
	get_tree().change_scene_to_file("res://ui/views/TitleScreen.tscn")

#func _ready() -> void:
	#print("Current Save")
	#print(UserData.currentSave.saveName)
