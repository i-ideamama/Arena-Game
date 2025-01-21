extends Node

var player = preload("res://Scenes/player.tscn")
var other_player = preload("res://Scenes/other_player.tscn")
var player_s_pos = Vector2.ZERO

var other_player_id

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_server():
	var client = ENetMultiplayerPeer.new()
	var err = client.create_client("127.0.0.1", 4243)
	if(err!=OK):
		print("Unable to connect to server.")
		return
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
func update_player_pos(id, pos):
	if(multiplayer.get_unique_id() == id):
		Nodes.get_node(str(id)).global_position = pos


@rpc("authority", "call_remote", "unreliable")
func update_other_player_pos(pos):
	if(Nodes.get_node(str(other_player_id))!=null):
		Nodes.get_node(str(other_player_id)).global_position = pos

@rpc("authority", "call_remote", "reliable")
func update_other_player_details(connected_players):
	for c in connected_players:
		if !(multiplayer.get_unique_id() == int(c)):
			other_player_id = int(c)


@rpc
func apply_impulse_on_player_s(id, force):
	pass

@rpc
func get_other_player_s_pos(id):
	pass

@rpc
func get_player_s_pos(id):
	pass
