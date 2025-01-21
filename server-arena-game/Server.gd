extends Node

var map  = preload("res://Scenes/Map.tscn")
var player_scene = preload("res://Scenes/player.tscn")
var m
var player_spawn_pos = Vector2(200,200)

var connected_players = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_shit()


func setup_shit() -> void:
	var server = ENetMultiplayerPeer.new()
	var err = server.create_server(4243)
	if err != OK:
		print("Error starting server.")
		return
	
	multiplayer.multiplayer_peer = server
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	print("Server created.")
	StartGame()
	print("Game started.")

func StartGame():
	m = map.instantiate()
	add_child(m)


func _on_player_connected(id):
	print("Player connected " + str(id))
	rpc_id(0, "instance_player", id, player_spawn_pos)
	
	var player = player_scene.instantiate()
	m.add_child(player)
	player.position = player_spawn_pos
	player.name = str(id)
	connected_players.append(str(id))
	
	for c in connected_players:
		rpc_id(int(c), "update_other_player_details", connected_players)


func _on_player_disconnected(id):
	print("Player disconnected " + str(id))
	connected_players.erase(str(id))
	for c in get_node("Map").get_children():
		if (c.name == str(id)) and (c.is_in_group("player")):
			c.queue_free()
	rpc_id(0, "delete_obj", id)
	
	for c in connected_players:
		rpc_id(int(c), "update_other_player_details", connected_players)

@rpc
func instance_player(id, location):
	pass

@rpc
func delete_obj(id):
	pass

@rpc("any_peer", "call_remote", "reliable")
func apply_impulse_on_player_s(id, force):
	m.get_node(str(id)).apply_central_impulse(force)

@rpc("any_peer", "call_remote", "unreliable")
func get_player_s_pos(id):
	rpc_id(id, "update_player_pos", id, m.get_node(str(id)).global_position)

@rpc("any_peer", "call_remote", "unreliable")
func get_other_player_s_pos(id, other_id):
	if(m.get_node_or_null(str(other_id))!=null):
		rpc_id(id, "update_other_player_pos", m.get_node(str(other_id)).global_position)
		

@rpc
func update_player_pos(id, pos):
	pass

@rpc
func update_other_player_pos(pos):
	pass

@rpc
func update_other_player_details(connected_players):
	pass
