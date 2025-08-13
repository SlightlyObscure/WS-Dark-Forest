extends Button

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Continue"):
		self._pressed()

func _pressed() -> void:
	Audio.playSound(Enums.Sound.click)
	get_tree().change_scene_to_file("res://ui/views/CharacterCreationScreen.tscn")
