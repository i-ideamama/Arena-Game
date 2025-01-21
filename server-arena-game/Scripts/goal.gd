extends StaticBody2D

var goal_number : int

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.name=="ball"):
		Server.rpc_id(1, "goal_scored", goal_number)
