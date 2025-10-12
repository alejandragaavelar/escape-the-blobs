extends Control

signal start_game
signal open_settings

func _ready():
	
	$VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	
	
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	emit_signal("start_game")
	queue_free() 

func _on_settings_button_pressed():
	
	$VBoxContainer.hide()
	$SettingsPanel.show()

func _on_quit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	$SettingsPanel.hide()
	$VBoxContainer.show()

func _on_music_volume_changed(value):

	var music_bus_idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))

func _on_sfx_volume_changed(value):

	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))

func _on_fullscreen_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
