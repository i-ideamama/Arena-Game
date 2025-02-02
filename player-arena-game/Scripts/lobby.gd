extends Node2D


func hide_elements() -> void:
	$Join.queue_free()
	$LobbyManagerButton.queue_free()


func _on_join_pressed() -> void:
	Server.join_server()
	$Join.disabled = true
	$Join.hide()


func _on_lobby_manager_button_pressed() -> void:
	Server.join_lobby_manager()
	hide_elements()
