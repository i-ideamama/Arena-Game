extends Node2D


func hide_elements() -> void:
	$Control2/ButtonContainer.hide()


func _on_join_pressed() -> void:
	Server.join_server()
	$Control2/ButtonContainer/VBoxContainer/Join.disabled = true
	$ButtonContainer/VBoxContainer/Join.hide()


func _on_lobby_manager_button_pressed() -> void:
	Server.join_lobby_manager()
	hide_elements()
