extends Node

const LOBBY_PORT = Global.LOBBY_PORT
const PORT = Global.PORT
const DEFAULT_SERVER_IP = Global.SERVER_IP

var ball_scene = preload("res://Scenes/ball.tscn")
var player = preload("res://Scenes/player.tscn")
var other_player = preload("res://Scenes/other_player.tscn")
var player_s_pos = Vector2.ZERO
var goal_scene = preload("res://Scenes/goal.tscn")
var orb_scene = preload("res://Scenes/orb.tscn")

var other_player_id

func _ready() -> void:
	spawn_elements()
	
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	
	var ball = ball_scene.instantiate()
	Nodes.add_child(ball)
	ball.position = Vector2(540, 1200)

func spawn_elements():
	# spawn goals
	Global.instance_node(goal_scene, Nodes, Global.GOAL_1_SPAWN_POINT, deg_to_rad(180))
	Global.instance_node(goal_scene, Nodes, Global.GOAL_2_SPAWN_POINT)

func join_server(port=null):
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		#reset_networked_nodes()
		
	
	var client = WebSocketMultiplayerPeer.new()
	var address
	# address = "144.24.133.118"
	address = ""
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	multiplayer.multiplayer_peer = null
	var error
	if Global.USE_SSL:
		var cert = null
		var tlsOptions = TLSOptions.client(cert)
		if(port==null):
			error = client.create_client("wss://" + address + ":" + str(PORT), tlsOptions)
		else:
			error = client.create_client("wss://" + address + ":" + str(port), tlsOptions)
		print(error)
	else:
		if(port==null):
			error = client.create_client("ws://" + address + ":" + str(PORT))
		else:
			error = client.create_client("ws://" + address + ":" + str(port))
	if error:
		return error
	multiplayer.multiplayer_peer = client
	

func join_lobby_manager():
	var client = WebSocketMultiplayerPeer.new()
	
	var address
	address = ""
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	multiplayer.multiplayer_peer = null
	var error
	if Global.USE_SSL:
		var cert = null
		var tlsOptions = TLSOptions.client(cert)
		error = client.create_client("wss://" + address + ":" + str(LOBBY_PORT), tlsOptions)
		print(error)
	else:
		error = client.create_client("ws://" + address + ":" + str(LOBBY_PORT))
	if error:
		return error
	multiplayer.multiplayer_peer = client

func _on_connected_ok():
	print("Connected to server.")

func _on_connected_fail():
	print("Connection to server failed.")
	

func _on_server_disconnected():
	print("Server disconnected.")

@rpc("authority", "call_remote", "reliable")
func instance_player(id, location):
	var p = player if multiplayer.get_unique_id()==id else other_player
	var player_instance = Global.instance_node(p, Nodes, location)
	player_instance.name = str(id)
	if multiplayer.get_unique_id() == id:
		for i in multiplayer.get_peers():
			if(i != 1):
				instance_player(i, location)


@rpc("authority", "call_remote", "reliable")
func delete_obj(id):
	if(Nodes.has_node(str(id))):
		Nodes.get_node(str(id)).queue_free()

@rpc("authority", "call_remote", "unreliable")
func update_player_pos(id, pos, rot):
	if(multiplayer.get_unique_id() == id):
		Nodes.get_node(str(id)).global_position = pos
		Nodes.get_node(str(id)).rotation = rot


@rpc("authority", "call_remote", "unreliable")
func update_other_player_pos(pos, rot):
	if(Nodes.get_node(str(other_player_id))!=null):
		Nodes.get_node(str(other_player_id)).global_position = pos
		Nodes.get_node(str(other_player_id)).rotation = rot

@rpc("authority", "call_remote", "reliable")
func update_other_player_details(connected_players: Array):
	for c in connected_players:
		if !(multiplayer.get_unique_id() == int(c)):
			other_player_id = int(c)

@rpc("authority", "call_remote", "reliable")
func update_ball_pos(pos, rot):
	Nodes.get_node("ball").position = pos
	Nodes.get_node("ball").rotation = rot

@rpc("authority", "call_remote", "reliable")
func change_player_stat(id, stat):
	if(stat == 0):
		if(int(id)==int(multiplayer.get_unique_id())):
			Nodes.get_node(str(multiplayer.get_unique_id())).get_node("SpeedTimer").start()
	elif(stat == 1):
		if(int(id)==int(multiplayer.get_unique_id())):
			Nodes.get_node(str(multiplayer.get_unique_id())).get_node("SizeTimer").start()
			Nodes.get_node(str(multiplayer.get_unique_id())).scale = Vector2(Global.PUP_PLAYER_SCALE,Global.PUP_PLAYER_SCALE)
		else:
			Nodes.get_node(str(other_player_id)).scale = Vector2(Global.PUP_PLAYER_SCALE,Global.PUP_PLAYER_SCALE)


@rpc("any_peer","call_local","reliable")
func reset_player_stat(id, stat):
	rpc_id(1, "reset_player_stat_s", multiplayer.get_unique_id(), stat)
	if(stat == 0):
		pass
	elif(stat == 1):
		if(id==multiplayer.get_unique_id()):
			Nodes.get_node(str(multiplayer.get_unique_id())).scale = Vector2(Global.DEFAULT_PLAYER_SCALE,Global.DEFAULT_PLAYER_SCALE)
		else:
			Nodes.get_node(str(other_player_id)).scale = Vector2(Global.DEFAULT_PLAYER_SCALE,Global.DEFAULT_PLAYER_SCALE)

@rpc("authority","call_remote","reliable")
func update_score_display(scorer_id):
	if(int(scorer_id)==multiplayer.get_unique_id()):
		get_parent().get_node("Lobby").get_node("Control2").get_node("OS").get_node("OS").get_node("OwnScore").text = str(int(get_parent().get_node("Lobby").get_node("Control2").get_node("OS").get_node("OS").get_node("OwnScore").text)+1)
	else:
		get_parent().get_node("Lobby").get_node("Control2").get_node("OpS").get_node("OpS").get_node("OppScore").text = str(int(get_parent().get_node("Lobby").get_node("Control2").get_node("OpS").get_node("OpS").get_node("OppScore").text)+1)

@rpc
func spawn_orb():
	pass

@rpc
func despawn_orbs():
	pass

@rpc("authority","call_remote","reliable")
func spawn_orbs_in_player(pos):
	var orb = orb_scene.instantiate()
	Nodes.add_child(orb)
	orb.global_position = pos

@rpc("authority","call_remote","reliable")
func despawn_orbs_in_player():
	print('jasdfl')
	for c in Nodes.get_children():
		if(c.is_in_group("orb")):
			print("hi")
			Nodes.call_deferred("remove_child", c)
			#Nodes.remove_child(c)
			c.queue_free()

@rpc
func apply_impulse_on_player_s(id, force):
	pass

@rpc
func get_other_player_s_pos(id):
	pass

@rpc
func get_player_s_pos(id):
	pass

@rpc
func get_ball_pos():
	pass

@rpc
func goal_scored(scorer_id):
	pass

@rpc
func change_player_stat_s(id, stat):
	pass

@rpc
func reset_player_stat_s(id, stat):
	pass

@rpc
func send_update_to_player_timer():
	pass

@rpc("authority","call_remote","reliable")
func update_player_timer():
	Global.seconds_passed+=1
	get_parent().get_node("Lobby").get_node("elapsed_time").text=str(Global.seconds_passed)

### STUFF FOR LOBBY MANAGEMENT ###

@rpc
func remove_from_waiting(id):
	pass

@rpc("authority", "call_remote", "reliable")
func player_join_game_at_port(port):
	await get_tree().create_timer(0.5).timeout
	switch_to_game_at_port(port)


func switch_to_game_at_port(port):
	var old_id = multiplayer.get_unique_id()
	rpc_id(0, "remove_from_waiting", old_id)
	multiplayer.multiplayer_peer = null
	join_server(port)
