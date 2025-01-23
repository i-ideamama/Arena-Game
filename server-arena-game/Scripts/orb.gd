extends Node2D

var powerup : Global.PUP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random = RandomNumberGenerator.new()
	random.randomize()
	var orb_sprite_number = randi() % 18
	$Sprite2D.texture = load("res://Assets/Orbs/Orb_"+str(orb_sprite_number)+".png")
	
	#powerup = randi() % Global.PUP.size()
	powerup = 0
	print('powerup number = '+str(powerup))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player")):
		Server.rpc_id(1, "change_player_stat_s", str(body.name), powerup)
