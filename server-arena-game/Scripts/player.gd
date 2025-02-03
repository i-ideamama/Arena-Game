extends RigidBody2D


var reset_state = false
var moveVector: Vector2

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform2D(0.0, moveVector)
		reset_state = false
		
		set_deferred("linear_velocity", Vector2.ZERO)
		set_deferred("angular_velocity", 0)
		set_deferred("rotation", 0)


func move_body(targetPos: Vector2):
	moveVector = targetPos;
	reset_state = true;
