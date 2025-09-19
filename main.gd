extends Node
@export var mob_scene: PackedScene
@export var coin_scene: PackedScene
var score
var coins_collected = 0
var current_level = 1
var game_time = 0.0
var level_up_time = 15.0  # Level up every 15 seconds

func _ready():
	# Connect the new damaged signal
	$Player.damaged.connect(_on_player_damaged)

func _process(delta):
	# Track game time during active gameplay
	if not $ScoreTimer.is_stopped():
		game_time += delta
		
		# Check for level up
		var expected_level = int(game_time / level_up_time) + 1
		if expected_level > current_level:
			level_up()

func level_up():
	current_level += 1
	$HUD.show_level_up(current_level)
	$HUD.update_level(current_level)
	
	# Increase difficulty based on level
	increase_difficulty()
	
	# Optional: Play level up sound
	# $LevelUpSound.play()
	
	# Give player some health back as reward
	$Player.heal(25)
	$HUD.update_health($Player.current_health)

func increase_difficulty():
	# Spawn mobs more frequently
	var new_mob_wait_time = max(0.3, $MobTimer.wait_time - 0.1)
	$MobTimer.wait_time = new_mob_wait_time
	
	# Spawn coins more frequently too (as reward)
	var new_coin_wait_time = max(1.0, $CoinTimer.wait_time - 0.2)
	$CoinTimer.wait_time = new_coin_wait_time
	
	# Optional: Increase mob speed (you'd need to modify mob spawning)
	# This requires storing base speed values and multiplying by level

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$CoinTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	coins_collected = 0
	current_level = 1
	game_time = 0.0
	
	# Reset timer speeds to default
	$MobTimer.wait_time = 0.5  # Set your default mob spawn rate
	$CoinTimer.wait_time = 3.0  # Set your default coin spawn rate
	
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_coins(coins_collected)
	$HUD.update_health($Player.current_health)
	$HUD.update_level(current_level)  # Show initial level
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("coins", "queue_free")
	$Music.play()

# Handle player taking damage
func _on_player_damaged(health):
	$HUD.update_health(health)
	# Optional: Play damage sound
	# $DamageSound.play()

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	$CoinTimer.start()

func _on_mob_timer_timeout():
	if mob_scene == null:
		print("Error: mob_scene is not assigned in the editor!")
		return
		
	var mob = mob_scene.instantiate()
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Scale mob speed based on level for increased difficulty
	var base_speed = randf_range(150.0, 250.0)
	var level_speed_multiplier = 1.0 + (current_level - 1) * 0.1  # 10% faster per level
	var velocity = Vector2(base_speed * level_speed_multiplier, 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	add_child(mob)

func _on_coin_timer_timeout():
	if coin_scene == null:
		print("Error: coin_scene is not assigned in the editor!")
		return
		
	var coin = coin_scene.instantiate()
	var viewport = get_viewport().get_visible_rect()
	coin.position.x = randf_range(50, viewport.size.x - 50)
	coin.position.y = -50
	var horizontal_velocity = randf_range(-50.0, 50.0)
	coin.linear_velocity = Vector2(horizontal_velocity, randf_range(100.0, 200.0))
	coin.connect("coin_collected", _on_coin_collected)
	add_child(coin)

func _on_coin_collected():
	coins_collected += 1
	score += 5
	$HUD.update_score(score)
	$HUD.update_coins(coins_collected)
	$CoinSound.play()
