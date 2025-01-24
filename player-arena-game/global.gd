extends Node

const SERVER_IP := "144.24.133.118"
const PORT := 6000
const USE_SSL := false # put certs in assets/certs, a free let's encrypt one works for itch.io
const TRUSTED_CHAIN_PATH := ""
const PRIVATE_KEY_PATH := ""

var BALL_SPAWN_POINT

const DEFAULT_PLAYER_MASS = 2
const PUP_PLAYER_MASS = 0.8

const DEFAULT_PLAYER_SCALE = 1
const PUP_PLAYER_SCALE = 1.5

var GOAL_1_SPAWN_POINT = Vector2(536,152)
var GOAL_2_SPAWN_POINT = Vector2(536,2200)

const POWERUP_TIMER_TIMEOUT := 5.0

enum PUP {SPEED=0, SIZE=1}

func instance_node(node, parent, location, rot = 0):
	var node_instance = node.instantiate()
	node_instance.global_position = location
	node_instance.rotation = rot
	parent.add_child(node_instance)
	return node_instance
