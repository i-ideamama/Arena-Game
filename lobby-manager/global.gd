extends Node

const SERVER_IP := "localhost"
const PORT := 8911
const USE_SSL := false # put certs in assets/certs, a free let's encrypt one works for itch.io
const TRUSTED_CHAIN_PATH := "res://assets/certs/development.crt"
const PRIVATE_KEY_PATH := "res://assets/certs/development.key"

# use ports from 9000-10000
