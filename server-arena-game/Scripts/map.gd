extends Node2D


func _on_game_timer_timeout() -> void:
	Server.rpc_id(0, "winner_info", null)
	await get_tree().create_timer(0.5).timeout
	OS.kill(OS.get_process_id())


func _on_second_timer_timeout() -> void:
	if(Global.start_timer==true):
		Global.TIME_ELAPSED+=1
	Server.rpc_id(1, "send_update_to_player_timer")
	Server.rpc_id(1, "update_time_el")

func _on_pup_timer_timeout() -> void:
	Server.rpc_id(1, "despawn_orbs")
	Server.rpc_id(1, "spawn_orb")
