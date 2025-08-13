extends Button

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Continue") && self.disabled == false:
		self._pressed()

func _pressed() -> void:
	var parentNode: CharacterCreationScreenController = get_node("/root/CharacterCreationScreen")
	var saveName: String = (parentNode.get_node("SaveFileNameInput") as LineEdit).text
	
	var skills: Dictionary = {}
	for skillName: String in parentNode.skills:
		skills[skillName] = parentNode.skills[skillName].level

	var save: Save = Save.create(saveName, skills)
	UserData.addSave(save)
	UserData.currentSave = save
	
	Audio.playSound(Enums.Sound.click)
	get_tree().change_scene_to_file("res://ui/views/GameplayScreen.tscn")
