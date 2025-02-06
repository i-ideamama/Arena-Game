extends Node

var args
var PORT_TO_RUN_ON

# 0 -> game not over
# 1 -> game over
var GAME_STATE := 0

const SERVER_IP := "localhost"
#const PORT := 8910
const PORT := 9001
const USE_SSL := false  # put certs in assets/certs, a free let's encrypt one works for itch.io
const TRUSTED_CHAIN_PATH := "res://assets/certs/something.crt"
# const TRUSTED_CHAIN_PATH := "res://assets/certs/development.crt"
const PRIVATE_KEY_PATH := "res://assets/certs/something.key"
# const TRUSTED_CHAIN_PATH := "res://assets/certs/development.crt"

var start_timer = false
var TIME_ELAPSED := 0

const DEFAULT_PLAYER_MASS = 2
const PUP_PLAYER_MASS = 0.8

const DEFAULT_PLAYER_SCALE = 1
const PUP_PLAYER_SCALE = 1.5

const GOALS_TO_WIN = 3

# PowerUPs
enum PUP {SPEED=0, SIZE=1}

# enum PUP {SPEED, SIZE, GOAL_SWAP}

const BALL_RESET_POSITION = Vector2(540,1200)

# POSITIONS
var ORB_SPAWN_POINT = Vector2(540, 1200)

func _ready() -> void:
	args = Array(OS.get_cmdline_args())
	print("printing args below : ")
	PORT_TO_RUN_ON = int(args[0])
	print(PORT_TO_RUN_ON)
