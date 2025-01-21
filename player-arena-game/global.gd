extends Node

var BALL_SPAWN_POINT

var GOAL_1_SPAWN_POINT = Vector2(536,152)
var GOAL_2_SPAWN_POINT = Vector2(536,2200)

func instance_node(node, parent, location, rot = 0):
	var node_instance = node.instantiate()
	node_instance.global_position = location
	node_instance.rotation = rot
	parent.add_child(node_instance)
	return node_instance
