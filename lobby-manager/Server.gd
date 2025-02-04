extends Node


const PORT = Global.PORT
const DEFAULT_SERVER_IP = Global.SERVER_IP


var connected_players = []
var waiting_players = []

var currently_waiting_players = 0
# port where game server is currently running (for testing)
#var port = 9001

var thread : Thread

func _ready() -> void:
	#var command_output = []
	#var port = 9001
	#OS.execute("./GameServer.x86_64", [str(port)], command_output)
	#start_game_at_port(9001)
	setup_shit()
	
func check_port_status(port):
	print('check port status')
	var command_output = []
	var output
	OS.execute("./is_port_free.sh", [str(port)], command_output)
	output = int(command_output[0])
	return output

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

func match_players():
	print('match making in progress ... ')
	var p = get_free_port_to_run_on()
	
	thread = Thread.new()
	thread.start(start_game_at_port.bind(p))
	
	await get_tree().create_timer(1).timeout
	for player_id in waiting_players:
		# start game on players end (send this only to waiting players)
		rpc_id(int(player_id), "player_join_game_at_port", p)
	currently_waiting_players = 0

func start_game_at_port(port):
	print("trying to start game at "+str(port))
	var command_output = []
	OS.execute("./GameServer.x86_64", [str(port)], command_output)
	print(command_output)

func get_free_port_to_run_on():
	print("jelo")
	var found_free_port = false
	var current_port = Global.START_PORT
	while(found_free_port==false):
		if(check_port_status(current_port)==0):
			found_free_port=true
			print("Going to run on: "+str(current_port))
			return current_port
			
		else:
			current_port+=1

func _on_player_connected(id):
	print("Player connected " + str(id))
	connected_players.append(str(id))
	waiting_players.append(str(id))
	currently_waiting_players+=1
	print("currently waiting  = "+str(currently_waiting_players))

	if(currently_waiting_players==2):
		print('2 players waiting')
		match_players()
		

func _on_player_disconnected(id):
	print("Player disconnected " + str(id))
	connected_players.erase(str(id))

@rpc
func remove_from_waiting(id):
	waiting_players.erase(str(id))
	connected_players.erase(str(id))

@rpc
func player_join_game_at_port(port):
	pass

# kfjlajsdfja;lsdjfl
@rpc
func instance_player(id, location):
	pass
@rpc
func delete_obj(id):
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
func change_player_stat(id, stat):
	pass
@rpc
func reset_player_stat(id, stat):
	pass
@rpc
func update_score_display(scorer_id):
	pass


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

@rpc
func update_player_timer():
	pass
