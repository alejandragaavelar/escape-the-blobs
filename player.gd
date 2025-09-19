extends Area2D

signal hit
signal damaged(health)

@export var speed = 400
var screen_size
var max_health = 100
var current_health = 100
var invincible = false
var invincible_time = 2.0

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	current_health = max_health
	invincible = false

func _on_body_entered(body):
	if body.is_in_group("mobs"):
		if not invincible:
			take_damage(25)
		body.queue_free()
	
	elif body.is_in_group("coins"):
		body.coin_collected.emit()
		body.queue_free()

func take_damage(damage_amount):
	if invincible:
		return
		
	current_health -= damage_amount
	damaged.emit(current_health)
	
	start_invincibility()
	
	if current_health <= 0:
		current_health = 0
		hit.emit()
		hide()
		$CollisionShape2D.disabled = true

# New healing function for level up rewards
func heal(heal_amount):
	current_health = min(current_health + heal_amount, max_health)
	damaged.emit(current_health)  # Update HUD display
	
	# Optional: Visual healing effect
	var tween = create_tween()
	modulate = Color.GREEN
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)

func start_invincibility():
	invincible = true
	var tween = create_tween()
	tween.set_loops(int(invincible_time * 5))
	tween.tween_method(toggle_visibility, 0.0, 1.0, 0.2)
	
	await get_tree().create_timer(invincible_time).timeout
	invincible = false
	modulate.a = 1.0

func toggle_visibility(value):
	modulate.a = 0.5 if int(value * 10) % 2 == 0 else 1.0
