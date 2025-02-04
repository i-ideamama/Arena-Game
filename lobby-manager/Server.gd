extends Node


const PORT = Global.PORT
const DEFAULT_SERVER_IP = Global.SERVER_IP


var connected_players = []
var waiting_players = []

var currently_waiting_players = 0
# port where game server is currently running (for testing)
var port = 9000

var command_output = []
var output

func _ready() -> void:
	setup_shit()
	OS.execute("./is_port_free.sh", ["8912"], command_output)
	output = int(command_output[0])
	print(output)

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
	for player_id in waiting_players:
		rpc_id(int(player_id), "player_join_game_at_port", port)
		# start game on players end (send this only to waiting players)
	currently_waiting_players = 0


func _on_player_connected(id):
	print("Player connected " + str(id))
	connected_players.append(str(id))
	waiting_players.append(str(id))
	currently_waiting_players+=1
	if(currently_waiting_players==2):
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
