extends Node2D


func _on_game_timer_timeout() -> void:
	pass


func _on_second_timer_timeout() -> void:
	Server.rpc_id(1, "send_update_to_player_timer")


func _on_pup_timer_timeout() -> void:
	Server.rpc_id(1, "despawn_orbs")
	Server.rpc_id(1, "spawn_orb")
