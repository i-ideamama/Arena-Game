extends Node


var PORT
const DEFAULT_SERVER_IP = Global.SERVER_IP

var map  = preload("res://Scenes/Map.tscn")
var player_scene = preload("res://Scenes/player.tscn")
var m
var player_spawn_pos = Vector2(200,200)
var goal_scene = preload("res://Scenes/goal.tscn")
var orb_scene = preload("res://Scenes/orb.tscn")

var connected_players = []
var player_scores = [0, 0]

var ball_reset_position = Global.BALL_RESET_POSITION

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	#PORT = Global.PORT_TO_RUN_ON
	PORT = Global.PORT
	print('I am going to run on '+str(PORT))
	setup_shit()
	spawn_elements()


func setup_shit():
	var server = WebSocketMultiplayerPeer.new()
	var error
	if Global.USE_SSL:
		var priv := load(Global.PRIVATE_KEY_PATH)
		var cert := load(Global.TRUSTED_CHAIN_PATH)
		var tlsOptions = TLSOptions.server(priv, cert)
		error = server.create_server(PORT, "*", tlsOptions)
	else:
		error = server.create_server(PORT, "*")
	if error:
		return error
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
	goal.goal_number = 1
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
	
	## spawn orbs for powerups




func StartGame():
	m = map.instantiate()
	add_child(m)


func _on_player_connected(id):
	print("Player connected " + str(id))
	for c in get_children():
		if(c.name=="Map"):
			if(connected_players.size()<1):
				print('first')
				player_spawn_pos = c.get_node("SpawnLocations").get_node("2").global_position
			else:
				player_spawn_pos = c.get_node("SpawnLocations").get_node("1").global_position
	rpc_id(0, "instance_player", id, player_spawn_pos)

	var player = player_scene.instantiate()
	m.add_child(player)
	player.position = player_spawn_pos
	player.name = str(id)
	connected_players.append(str(id))
	print(connected_players)
	for c in connected_players:
		rpc_id(int(c), "update_other_player_details", connected_players)
	if(connected_players.size()>1):
		reset_positions()

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
	rpc("update_score_display", connected_players[goal_no])
	check_game_over(goal_no)
	reset_positions()

func check_game_over(goal_no):
	if(goal_no==1):
		player_scores[0]+=1
	elif(goal_no==0):
		player_scores[1]+=1
	var winner
	
	## the api call can be done somewhere here
	
	if(player_scores[0]>=Global.GOALS_TO_WIN):
		winner = connected_players[0]
		rpc_id(0, "winner_info", winner)
		OS.kill(OS.get_process_id())
	elif (player_scores[1]>=Global.GOALS_TO_WIN):
		winner = connected_players[1]
		rpc_id(0, "winner_info", winner)
		OS.kill(OS.get_process_id())

@rpc
func winner_info(winner_id):
	pass

func reset_positions():
	for c in get_children():
		if(c.name=="Map"):
			#c.set_deferred('get_node(str(connected_players[0])).move_body', c.get_node("SpawnLocations").get_node("1").global_position)
			c.get_node(str(connected_players[0])).move_body(c.get_node("SpawnLocations").get_node("1").global_position)
			#c.set_deferred('get_node(str(connected_players[1])).move_body', c.get_node("SpawnLocations").get_node("2").global_position)
			c.get_node(str(connected_players[1])).move_body(c.get_node("SpawnLocations").get_node("2").global_position)
			c.get_node("ball").move_body(ball_reset_position)
	rpc_id(0,"do_the_fades")

@rpc
func do_the_fades():
	pass

## ABILITIES
@rpc("authority", "call_local", "reliable")
func change_player_stat_s(id, stat):
	if(stat==0):
		m.get_node(str(id)).mass = Global.PUP_PLAYER_MASS
	elif(stat==1):
		var new_scale = Vector2(Global.PUP_PLAYER_SCALE,Global.PUP_PLAYER_SCALE)
		m.get_node(str(id)).get_node("CollisionShape2D").scale = new_scale
	rpc("change_player_stat", id, stat)
	
@rpc("any_peer","call_remote","reliable")
func reset_player_stat_s(id, stat):
	if(stat==0):
		m.get_node(str(id)).mass = Global.DEFAULT_PLAYER_MASS
	elif(stat==1):
		var new_scale = Vector2(Global.DEFAULT_PLAYER_SCALE,Global.DEFAULT_PLAYER_SCALE)
		m.get_node(str(id)).get_node("CollisionShape2D").scale = new_scale

@rpc("authority","call_local","reliable")
func send_update_to_player_timer():
	for p in connected_players:
		rpc_id(int(p),"update_player_timer")

@rpc("authority","call_local","reliable")
func spawn_orb():
	var orb = orb_scene.instantiate()
	orb.global_position = Global.ORB_SPAWN_POINT
	get_node("Map").add_child(orb)
	rpc_id(0, "spawn_orbs_in_player", Global.ORB_SPAWN_POINT)

@rpc("authority","call_local","reliable")
func despawn_orbs():
	for c in get_node("Map").get_children():
		if(c.is_in_group("orb")):
			get_node("Map").call_deferred("remove_child", c)
			c.queue_free()
	rpc_id(0, "despawn_orbs_in_player")
	
@rpc
func despawn_orbs_in_player():
	pass

@rpc
func spawn_orbs_in_player(pos):
	pass


func _on_timeout():
	queue_free()

@rpc()
func update_player_timer():
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

@rpc
func reset_player_stat(stat):
	pass

@rpc
func update_score_display(scorer_id):
	pass



# sdfasdfads
@rpc
func remove_from_waiting(id):
	pass

@rpc
func player_join_game_at_port(port):
	pass
