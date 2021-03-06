extends Node

signal configuration_changed(config)

const Res_directory = "res://"
const Settings_Path = Res_directory + "Settings.cfg"

# 0 : File didn't open
# 1 : File open
enum {LOAD_ERROR_COULDNT_OPEN, LOAD_SUCCESS}

var Settings = {
	"Display": 
	{
		"WIDTH": 1600,
		"HEIGHT": 900,
		"FullScreen": true,
		"Vsync": true,
		"Antialiasing": true,
		"Trees": "high",
		"RainDetails": "high",
		"CloudsQuality": 25,
		"GodRays": true
	},
	"Audio":
	{
		"MASTER": 0,
		"MUSIC": 0,
		"SOUND_EFFECTS": 0,
		"MUTE" : false
	},
	"Game":
	{
		"Language": "en",
		"ControlsHelper": true
	}
}

var _config = ConfigFile.new()


func _ready():
	
	Settings.Game.Language = TranslationServer.get_locale()
	
	#Check if settings.ini exist if not create a new one with the default Settings
	if load_settings() == LOAD_ERROR_COULDNT_OPEN :
		save_settings()
	apply_settings()


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func update_Settings(height, width, fullscreen, vsync, antialiasing, audio, mute):
	Settings.Display.HEIGHT = height
	Settings.Display.WIDTH = width
	Settings.Display.FullScreen = fullscreen
	Settings.Display.Vsync = vsync
	Settings.Display.Antialiasing = antialiasing
	Settings.Audio.MASTER = audio.x
	Settings.Audio.MUSIC = audio.y
	Settings.Audio.SOUND_EFFECTS = audio.z
	Settings.Audio.MUTE = mute
	#Saving the file than applying it
	apply_settings()
	save_settings()


func save_settings():
	for section in Settings.keys():
		for key in Settings[section]:
			_config.set_value(section, key, Settings[section][key])
	_config.save(Settings_Path)
	print("Save : ", Settings)


func apply_settings():
	# Check out the documentation about :
	# OS class : http://docs.godotengine.org/en/3.0/classes/class_os.html
	# Engine class : http://docs.godotengine.org/en/3.0/classes/class_engine.html
	# for this case i only use OS to change the resolution,fullscreen and Vsync 
	OS.window_size = Vector2(Settings.Display.WIDTH,Settings.Display.HEIGHT)
	OS.window_fullscreen = Settings.Display.FullScreen
	OS.vsync_enabled = Settings.Display.Vsync
	
	get_viewport().msaa = Viewport.MSAA_4X
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Settings.Audio.MASTER)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Settings.Audio.MUSIC)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SoundEffect"), Settings.Audio.SOUND_EFFECTS)
	
	if Settings.Audio.MUTE:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SoundEffect"), true)
	
	TranslationServer.set_locale( Settings.Game.Language )
	
	emit_signal("configuration_changed", Settings)


func load_settings():
	# Check for error if true exist the function else parse the file and load the config settings into Settings
	var error = _config.load(Settings_Path)
	if error != OK:
		push_error("Error loading the settings. Error code: %s" % error)
		return LOAD_ERROR_COULDNT_OPEN
	for section in Settings.keys():
		for key in Settings[section]:
			Settings[section][key] = _config.get_value(section, key, Settings[section][key])
			#if value != null:
			#	Settings[section][key] = value
	return LOAD_SUCCESS

