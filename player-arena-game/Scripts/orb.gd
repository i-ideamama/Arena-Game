extends Node2D

var powerup

func _ready() -> void:
	var random = RandomNumberGenerator.new()
	random.randomize()
	var orb_sprite_number = randi() % 18
	$Sprite2D.texture = load("res://Assets/Orbs/Orb_"+str(orb_sprite_number)+".png")
