extends Node


const PORT = Global.PORT
const DEFAULT_SERVER_IP = Global.SERVER_IP

var connected_players = []
var waiting_players = []


func _ready() -> void:
	setup_shit()


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


func _on_player_connected(id):
	print("Player connected " + str(id))
	connected_players.append(str(id))


func _on_player_disconnected(id):
	print("Player disconnected " + str(id))
	connected_players.erase(str(id))
