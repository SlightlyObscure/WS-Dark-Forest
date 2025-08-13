extends Control

class_name ConfirmDeleteSaveDialog

signal delete_confirmed()


func _on_cancel_pressed() -> void:
	Audio.playSound(Enums.Sound.click)
	queue_free()


func _on_delete_pressed() -> void:
	self.delete_confirmed.emit()
	Audio.playSound(Enums.Sound.click)
	queue_free()
