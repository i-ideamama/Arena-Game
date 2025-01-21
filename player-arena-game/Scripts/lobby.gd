extends Node2D



func _on_join_pressed() -> void:
	Server.join_server()
	$Join.disabled = true
	$Join.hide()
