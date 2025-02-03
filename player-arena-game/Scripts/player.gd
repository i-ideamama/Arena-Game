extends Node2D

var mouse_in_area := false
var initial_pos = null
var currently_aiming := false

func _ready() -> void:
	self.z_index = 100

func _process(delta: float) -> void:
	Server.rpc_id(1, "get_player_s_pos", multiplayer.get_unique_id())
	Server.rpc_id(1, "get_other_player_s_pos", multiplayer.get_unique_id() ,Server.other_player_id)
	Server.rpc_id(1, "get_ball_pos")
	

func _input(event):
	
	if (event is InputEventMouseButton):
		if event.button_index==1:
			if mouse_in_area and event.is_pressed():
				initial_pos = get_global_mouse_position()
				currently_aiming = true
			if (event.is_released() and currently_aiming):
				if initial_pos!=null:
					shoot_with_force((initial_pos - get_global_mouse_position()).normalized())

func shoot_with_force(dxn):
	var force_mag = 1250
	# Server.apply_impulse_on_player_s(multiplayer.get_unique_id() ,force_mag*dxn)
	Server.rpc_id(1, "apply_impulse_on_player_s", multiplayer.get_unique_id(), force_mag*dxn)
	currently_aiming = false

func _on_area_2d_mouse_entered() -> void:
	mouse_in_area = true

func _on_area_2d_mouse_exited() -> void:
	mouse_in_area = false


func _on_speed_timer_timeout() -> void:
	print('speed timer timeout')
	Server.rpc("reset_player_stat",multiplayer.get_unique_id(),0)
	$SpeedTimer.stop()

func _on_size_timer_timeout() -> void:
	print('size timer timeout')
	Server.rpc("reset_player_stat",multiplayer.get_unique_id(),1)
	$SizeTimer.stop()
	
