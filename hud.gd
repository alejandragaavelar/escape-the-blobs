extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	
	$Message.text = "Dodge the Shrooms!"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

# New level up notification
func show_level_up(level):
	# Create a temporary level up message
	var level_message = "LEVEL " + str(level) + "!"
	$LevelUpMessage.text = level_message
	$LevelUpMessage.show()
	
	# Create a scaling animation effect
	var tween = create_tween()
	tween.set_parallel(true)  # Allow multiple tweens to run simultaneously
	
	# Scale animation
	$LevelUpMessage.scale = Vector2(0.5, 0.5)
	tween.tween_property($LevelUpMessage, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property($LevelUpMessage, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.3)
	
	# Color animation (flash effect)
	$LevelUpMessage.modulate = Color.YELLOW
	tween.tween_property($LevelUpMessage, "modulate", Color.WHITE, 0.5)
	
	# Hide after 2 seconds
	await get_tree().create_timer(2.0).timeout
	$LevelUpMessage.hide()

func update_score(score):
	$ScoreLabel.text = str(score)

func update_coins(coins):
	$CoinLabel.text = "Coins: " + str(coins)

func update_health(health):
	$HealthLabel.text = "Health: " + str(health)
	
	# Color coding for health
	if health > 60:
		$HealthLabel.modulate = Color.GREEN
	elif health > 30:
		$HealthLabel.modulate = Color.YELLOW
	else:
		$HealthLabel.modulate = Color.RED

# New function to update level display
func update_level(level):
	$LevelLabel.text = "Level: " + str(level)
	
	# Optional: Color progression for higher levels
	if level >= 10:
		$LevelLabel.modulate = Color.GOLD
	elif level >= 5:
		$LevelLabel.modulate = Color.ORANGE
	else:
		$LevelLabel.modulate = Color.WHITE

func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
