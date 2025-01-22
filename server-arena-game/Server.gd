extends Node


const PORT = Global.PORT
const DEFAULT_SERVER_IP = Global.SERVER_IP

var map  = preload("res://Scenes/Map.tscn")
var player_scene = preload("res://Scenes/player.tscn")
var m
var player_spawn_pos = Vector2(200,200)
var goal_scene = preload("res://Scenes/goal.tscn")

var connected_players = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_shit()
	spawn_elements()


func setup_shit() -> void:	
	var server = WebSocketMultiplayerPeer.new()
	var err = server.create_server(PORT, "*")
	if err != OK:
		print("Cannot host " + str(err))
		return
	
	multiplayer.multiplayer_peer = server
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	print("Server created.")
	StartGame()
	print("Game started.")

func spawn_elements():
	var goal
	# spawn goal 1
	goal = goal_scene.instantiate()
	goal.goal_number = 14
	for c in get_children():
		if(c.name=="Map"):
			c.add_child(goal)
			goal.position = c.get_node("SpawnLocations").get_node("goal1").global_position
	# spawn goal 2
	goal = goal_scene.instantiate()
	goal.goal_number = 2
	for c in get_children():
		if(c.name=="Map"):
			c.add_child(goal)
			goal.position = c.get_node("SpawnLocations").get_node("goal2").global_position
	goal.rotation = 0
	

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


@rpc("any_peer", "call_remote", "reliable")
func apply_impulse_on_player_s(id, force):
	m.get_node(str(id)).apply_central_impulse(force)

@rpc("any_peer", "call_remote", "unreliable")
func get_player_s_pos(id):
	rpc_id(id, "update_player_pos", id, m.get_node(str(id)).global_position, m.get_node(str(id)).rotation)

@rpc("any_peer", "call_remote", "unreliable")
func get_other_player_s_pos(id, other_id):
	if(m.get_node_or_null(str(other_id))!=null):
		rpc_id(id, "update_other_player_pos", m.get_node(str(other_id)).global_position, m.get_node(str(other_id)).rotation)

@rpc("any_peer", "call_remote", "unreliable")
func get_ball_pos():
	rpc("update_ball_pos", m.get_node("ball").global_position, m.get_node("ball").rotation)



@rpc("authority", "call_local", "reliable")
func goal_scored(goal_no):
	goal_no-=1
	print('goal scored in players '+str(connected_players[goal_no])+' goal')

## ABILITIES
@rpc("authority", "call_local", "reliable")
func change_player_stat_s(id, stat):
	if(stat==0):
		print('speed')
		m.get_node(str(id)).mass = Global.PUP_PLAYER_MASS
	elif(stat==1):
		var new_scale = Vector2(Global.PUP_PLAYER_SCALE,Global.PUP_PLAYER_SCALE)
		m.get_node(str(id)).get_node("CollisionShape2D").scale = new_scale
		print('size')
	rpc_id(int(id), "change_player_stat", stat)
	


func _on_timeout():
	queue_free()

@rpc()
func reset_stats(id):
	pass

@rpc
func change_player_stat(id, stat):
	pass

@rpc
func update_player_pos(id, pos, rot):
	pass

@rpc
func update_other_player_pos(pos, rot):
	pass

@rpc
func update_other_player_details(connected_players):
	pass

@rpc
func update_ball_pos(pos, rot):
	pass

@rpc
func instance_player(id, location):
	pass

@rpc
func delete_obj(id):
	pass
