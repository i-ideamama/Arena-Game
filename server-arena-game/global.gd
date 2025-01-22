extends Node

const SERVER_IP := "localhost"
const PORT := 3131
const USE_SSL := false # put certs in assets/certs, a free let's encrypt one works for itch.io
const TRUSTED_CHAIN_PATH := ""
const PRIVATE_KEY_PATH := ""

const DEFAULT_PLAYER_MASS = 2
const PUP_PLAYER_MASS = 0.8

const DEFAULT_PLAYER_SCALE = 1
const PUP_PLAYER_SCALE = 1.5


# PowerUPs
enum PUP {SPEED=0, SIZE=1}

# enum PUP {SPEED, SIZE, GOAL_SWAP}
