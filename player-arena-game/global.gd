extends Node

var BALL_SPAWN_POINT

func instance_node(node, parent, location):
	var node_instance = node.instantiate()
	node_instance.global_position = location
	parent.add_child(node_instance)
	return node_instance

func init_globals():
	pass
