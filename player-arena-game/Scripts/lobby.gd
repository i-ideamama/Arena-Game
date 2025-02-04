#extends Node2D
extends Control 

func hide_elements() -> void:
	$Control2/ButtonContainer.hide()


func _on_join_pressed() -> void:
	Server.join_server()
	$Control2/ButtonContainer/VBoxContainer/Join.disabled = true
	$Control2/ButtonContainer.hide()


func _on_lobby_manager_button_pressed() -> void:
	Server.join_lobby_manager()
	hide_elements()
