extends RigidBody2D

signal coin_collected

func _ready():
	# Add coin to the "coins" group for easy cleanup
	add_to_group("coins")
	
	# Set up physics
	gravity_scale = 0.5  # Lighter gravity for floating effect
	
	# Connect area detection if using Area2D child
	if has_node("Area2D"):
		$Area2D.connect("body_entered", _on_body_entered)
	
	

func _on_body_entered(body):
	if body.name == "Player":
		
		emit_signal("coin_collected")
		queue_free()

func _cleanup_coin():
	
	queue_free()
