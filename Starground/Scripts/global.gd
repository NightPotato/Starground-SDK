extends Node

var itemsTable: Dictionary = {}
var buildingsTable: Dictionary = {}
var researchTable: Dictionary = {}
var recipeTable: Dictionary = {}
var cacheTable: Array = []
var lootTable: Dictionary = {}
var effectsTable: Dictionary = {}
var spawnerTable: Array = []
var uiSpawnerTable: Array = []

enum RESEARCH_TYPES{INFINITE, SINGLE, TIERED}
enum DAMAGE{SHARP, BLUNT, MAGIC}


var unlockedThings = []

var cachedResources = {}

var colors = {
	"Green": Color("#7FC675"), 
	"Red": Color("#FF7792"), 
	"White": Color(1, 1, 1, 1)
}



var currentConvertFormat = 1

var foundConvertFormat = currentConvertFormat

var virtualKeyboard

signal game_initialized
signal fully_loaded

signal fullscreen_changed
signal menu_loaded

var fuelIDs = []

var disconnected = false
var disconnectMessage = "Unknown"
var username = "Player"
var UIScale = 4
var mouseInWindow = true
var lobbyID
var lobbyType = 0
var basicsComplete = false
var completedTooltips = []
var hideChat = false
var rainActive = false
var rainInterval = Vector2(600, 3600)

var enabledMods = []
var loadedMods = []

var closeMenuDelay = 2
var currentCloseMenuDelay = 0


var inputType = INPUT.KEYBOARD
enum INPUT{KEYBOARD, CONTROLLER}

signal rain_changed

@onready var gameVersion = ProjectSettings.get_setting("application/config/version", "error")

var overlayObject
var hideUI = false

var genChunkSize = 32
var doResouceGen = true
var generationInfoDefaults = {
	"Seed": str(randi()),
	"TerrainScale": 0.02,
	"Size": 128,
	"WaterLevel": 0.5,
}

var generationInfo = generationInfoDefaults.duplicate(true)


var guideOpen = false
var showFPS = false
var showOverlay = false
var fontType = 0
var vsyncMode = 0
var screenshake = 1.0
var tutorial = true
var hidePlayerNames = false
var hideRain = false
var hitFirst = false
var minimapSize = 192
var minimapTransparency = 0.75

var modWarningAcknowledged = false

var controllerActive = false

var ingame = false

var dayCycle = true

enum {AUTOMATION, HUB, DUNGEON_1, DUNGEON_2}
var currentRegion = AUTOMATION

var manualDisconnect = false

var multiplayerID = 1




var musicPlayer
var ambiencePlayer
var stopMusic = false
var stopAmbience = false
var fadeTime = 1
var fadeIn = false
var musicDelay = false

var activePlayer = null
var heldItem

var voices = DisplayServer.tts_get_voices_for_language("en")
var voice_id = null

var activeLocation = ""

var userDataTimer = 10
var currentUserDataTimer = userDataTimer

var activeResearch = ""

# func read_mod_info(modFile):
# 	var info
# 	var reader = ZIPReader.new()

# 	var err = reader.open(modFile)
# 	if err == OK:
# 		if reader.file_exists("info.json"):
# 			var modInfo = reader.read_file("info.json")
# 			if modInfo:
# 				var convertedData = modInfo.get_string_from_utf8()
# 				if convertedData:
# 					info = JSON.parse_string(convertedData)

# 		reader.close()
# 	return info


# func validate_mod(modFile):
# 	var reader = ZIPReader.new()

# 	var bannedKeywords = [
# 		"OS.",
# 		"DirAccess.",
# 		"ResourceLoader.",
# 		"ResourceSaver.",
# 		"IP.",
# 		"FileAccess.",
# 		"Steam.",
# 	]

# 	var err = reader.open(modFile)
# 	if err == OK:
# 		var files = reader.get_files()
# 		for i in files:
# 			if i.get_extension() == "gdc":
# 				print("Mod uses binary tokenization for GDScript! Change this in the export settings to text only.\n")
# 				return false

# 			if i == "global.gd":
# 				print("global.gd replacement detected! Remove global.gd to allow loading.\n")
# 				return false

# 			if i.get_extension() == "gd":
# 				var file = reader.read_file(i)
# 				var readableFile = file.get_string_from_utf8()

# 				for j in bannedKeywords:
# 					if readableFile.find(j) > 0:
# 						print("Dangerous use of " + j + " in " + i + " detected! Remove use of this function to allow loading.\n")
# 						return false

# 		reader.close()
# 	return true


# func check_mod_file(modFile, subFile):
# 	var hasFile = false
# 	var reader = ZIPReader.new()

# 	var err = reader.open(modFile)
# 	if err == OK:
# 		hasFile = reader.file_exists(subFile)
# 		reader.close()
# 	return hasFile


# func load_mods():
# 	var dir = DirAccess.open("user://mods")
# 	if dir:
# 		dir.list_dir_begin()
# 		var modFile = dir.get_next()
# 		while modFile != "":
# 			var modPath = "user://mods/" + modFile

# 			var info = read_mod_info(modPath)
# 			if info:
# 				if enabledMods.has(info.Data.ID):
# 					print("Loading mod " + info.Data.ID)

# 					if validate_mod(modPath):
# 						# TODO: Rewrite to Support not Export Projects
# 						var success = ProjectSettings.load_resource_pack(modPath, true)
# 						if success:
# 							print("Loaded mod " + info.Data.ID)
# 							Global.loadedMods.push_back(info.Data.ID)

# 							var scriptPath = info.get("Script")
# 							if scriptPath:
# 								if ResourceLoader.exists(scriptPath):

# 									var node = Node.new()
# 									node.name = info.Data.ID
# 									node.set_script(load(scriptPath))
# 									ModAPI.add_child.call_deferred(node, true)
# 									# var _initialLoadScript = load(scriptPath).new()
# 									print("Ran " + scriptPath + " for " + info.Data.ID)
# 								else :
# 									print("Script at " + scriptPath + " not found!")
# 			else :
# 				print("Failed to load mod at " + modPath + ": No info.json file found!")

# 			modFile = dir.get_next()


# 	for i in Global.enabledMods:
# 		if !loadedMods.has(i):
# 			enabledMods.erase(i)



func sin_range(minNum, maxNum, t):
	var halfRange = (maxNum - minNum) / 2.0
	return minNum + halfRange + sin(t) * halfRange



func weighted_select(loot):
	var sum = 0.0
	for i in loot:
		sum += i[0]

	var rand = randf_range(0.0, sum)

	for i in loot:
		if rand < i[0]:
			return i
		rand -= i[0]


func get_closest_player_target(position):
	var dist = INF
	var node

	for i in get_tree().get_nodes_in_group("Players"):
		if !i.hasDied:
			if position.distance_to(i.global_position) < dist:
				node = i
				dist = position.distance_to(i.global_position)

	return node


func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func _unhandled_input(event):
	if event is InputEventJoypadButton:
		inputType = INPUT.CONTROLLER
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif event is InputEventKey:
		inputType = INPUT.KEYBOARD
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func get_closest_node(position, groupName):
	var dist = INF
	var node

	for i in get_tree().get_nodes_in_group(groupName):
		if position.distance_to(i.global_position) < dist:
			node = i
			dist = position.distance_to(i.global_position)

	return node


func save_user_settings():
	var file = FileAccess.open("user://userdata.dat", FileAccess.WRITE)

	var keybinds = {}

	for i in InputMap.get_actions():
		if !i.begins_with("ui_"):
			if InputMap.action_get_events(i).size() >= 1:
				keybinds.merge({i: InputMap.action_get_events(i)})

	if file != null:
		var userData = {
			"MasterVolume": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")), 
			"MusicVolume": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")), 
			"SoundEffectsVolume": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound Effects")), 
			"Username": username, 
			"UIScale": get_window().content_scale_factor, 
			"GuideOpen": guideOpen, 
			"ShowFPS": showFPS, 
			"Language": TranslationServer.get_locale(), 
			"FontType": fontType, 
			"VSyncMode": vsyncMode, 
			"MaxFPS": Engine.max_fps, 
			"Screenshake": screenshake, 
			"Keybinds": keybinds, 
			"HideChat": hideChat, 
			"HidePlayerNames": hidePlayerNames, 
			"MusicDelay": musicDelay, 
			"HideRain": hideRain, 
			"HitFirst": hitFirst, 
			"Fullscreen": DisplayServer.window_get_mode(), 
			"Tutorial": tutorial, 
			"MinimapSize": minimapSize, 
			"MinimapTransparency": minimapTransparency, 
			"EnabledMods": enabledMods, 
			"ModWarningAcknowledged": modWarningAcknowledged, 
		}

		file.store_var(userData, true)

	else :
		print("Error saving user data!")


var lastWindowType = DisplayServer.window_get_mode()

func window_change(mode):
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		lastWindowType = DisplayServer.window_get_mode()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else :
		if lastWindowType == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

	fullscreen_changed.emit(mode)


func load_user_settings():
	var file = FileAccess.open("user://userdata.dat", FileAccess.READ)

	if file != null:
		var userData = file.get_var(true)

		if userData:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), userData.get("MasterVolume", 0.0))
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), userData.get("MusicVolume", 0.0))
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), userData.get("SoundEffectsVolume", 0.0))
			username = userData.get("Username", "Player")
			get_window().content_scale_factor = userData.get("UIScale", 1)
			guideOpen = userData.get("GuideOpen", true)
			showFPS = userData.get("ShowFPS", false)

			var language = userData.get("Language", "en")
			TranslationServer.set_locale(language)

			fontType = userData.get("FontType", 0)
			set_font(fontType)
			vsyncMode = userData.get("VSyncMode", 0)
			Engine.max_fps = userData.get("MaxFPS", 0)
			screenshake = userData.get("Screenshake", 1.0)
			hideChat = userData.get("HideChat", false)
			hidePlayerNames = userData.get("HidePlayerNames", false)
			hideRain = userData.get("HideRain", false)
			musicDelay = userData.get("MusicDelay", false)
			hitFirst = userData.get("HitFirst", false)
			tutorial = userData.get("Tutorial", true)
			minimapSize = userData.get("MinimapSize", 192)
			minimapTransparency = userData.get("minimapTransparency", 0.75)
			enabledMods = userData.get("EnabledMods", [])
			modWarningAcknowledged = userData.get("ModWarningAcknowledged", false)

			var window = userData.get("Fullscreen", DisplayServer.WINDOW_MODE_WINDOWED)
			if window != DisplayServer.WINDOW_MODE_WINDOWED:
				window_change(window)

			var keybinds = userData.get("Keybinds", null)

			if keybinds:
				for i in keybinds:
					var event = keybinds.get(i)
					InputMap.action_erase_events(i)

					for j in event:
						InputMap.action_add_event(i, j)

			print("Loaded user data")
	else :
		var setLanguage = OS.get_locale_language()

		if TranslationServer.get_loaded_locales().has(setLanguage):
			TranslationServer.set_locale(setLanguage)

		print("Userdata not found")


func set_font(type = 0):
	fontType = type
	if type == 0:
		ThemeDB.get_project_theme().default_font = load("res://Fonts/LycheeSoda.ttf")
		ThemeDB.get_project_theme().default_font_size = 16

		ThemeDB.get_project_theme().set_font_size("font_size", "HeaderLarge", 32)
		ThemeDB.get_project_theme().set_font_size("font_size", "HeaderMedium", 24)
	else :
		ThemeDB.get_project_theme().default_font = load("res://Fonts/NotoSans-SemiBold.ttf")
		ThemeDB.get_project_theme().default_font_size = 12

		ThemeDB.get_project_theme().set_font_size("font_size", "HeaderLarge", 24)
		ThemeDB.get_project_theme().set_font_size("font_size", "HeaderMedium", 18)


func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouseInWindow = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		mouseInWindow = false


func is_in_dungeon():
	return currentRegion == DUNGEON_1 || currentRegion == DUNGEON_2

func _process(delta):
	if currentCloseMenuDelay > 0:
		currentCloseMenuDelay -= 1

	if controllerActive:
		if !get_viewport().gui_get_focus_owner():
			if virtualKeyboard.visible:
				var newFocus = virtualKeyboard.find_next_valid_focus()
				if !newFocus.is_in_group("NoAutofocus"):
					newFocus.grab_focus()
			else :
				for i in get_tree().get_nodes_in_group("CanvasFocus"):
					if i.visible:
						for j in i.get_children():
							if j is Control:
								var newFocus = j.find_next_valid_focus()
								if is_instance_valid(newFocus):
									if !(newFocus is RichTextLabel):
										if !newFocus.is_in_group("NoAutofocus"):
											newFocus.grab_focus()
		elif get_viewport().gui_get_focus_owner() is RichTextLabel:
			get_viewport().gui_get_focus_owner().release_focus()
	elif virtualKeyboard.visible:
		virtualKeyboard.close()

	controllerActive = inputType == INPUT.CONTROLLER

	if currentUserDataTimer <= 0:
		currentUserDataTimer = userDataTimer
		save_user_settings()
	else :
		currentUserDataTimer -= 1 * delta

	var sfxBus = AudioServer.get_bus_index("Sound Effects")

	if currentRegion == DUNGEON_1 || currentRegion == DUNGEON_2:
		AudioServer.set_bus_effect_enabled(sfxBus, 0, true)
	else :
		AudioServer.set_bus_effect_enabled(sfxBus, 0, false)

	if stopMusic:
		musicPlayer.volume_db -= (1.0 / fadeTime) * clampf(delta, 0, 0.1) * 60

		if musicPlayer.volume_db <= -60:
			musicPlayer.restart()
			stopMusic = false
	elif fadeIn:
		if musicPlayer.volume_db < musicPlayer.musicMaximum:
			musicPlayer.volume_db += (1.0 / fadeTime) * clampf(delta, 0, 0.1) * 60

	if stopAmbience:
		ambiencePlayer.volume_db -= (1.0 / 2.0) * clampf(delta, 0, 0.1) * 60

		if ambiencePlayer.volume_db <= -60:
			ambiencePlayer.restart()
			stopAmbience = false


func stop_ambience():
	stopAmbience = true


func stop_music(newFadeTime):
	stop_ambience()
	stopMusic = true
	fadeTime = newFadeTime
	set_music_override(null)


func only_stop_music(newFadeTime):
	stopMusic = true
	fadeTime = newFadeTime


func set_music_override(track):
	musicPlayer.override = track


func cache_resources():
	for i in cacheTable:
		var resource = ResourceLoader.load(i, "", ResourceLoader.CACHE_MODE_REUSE)
		cachedResources.merge({i: resource})


func _ready():
	if !DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_absolute("user://saves")

	if !DirAccess.dir_exists_absolute("user://mods"):
		DirAccess.make_dir_absolute("user://mods")

	load_user_settings()
	EnhancedModLoader.load_mods()

	var cache = load("res://Resources/caching_table.tres")
	cacheTable.append_array(cache.cacheTable)

	var loot = load("res://Resources/loot_table.tres")
	for i in loot.lootTable.keys():
		var lootArray = loot.lootTable.get(i)
		if lootTable.has(i):
			for j in lootArray:
				lootTable[i].push_back(j)
		else :
			lootTable.merge({i: lootArray})

	var building = load("res://Resources/buildings_table.tres")
	buildingsTable.merge(building.buildingsTable)
	building.buildingsTable = buildingsTable
	building.build()

	var research = load("res://Resources/research_table.tres")
	researchTable.merge(research.researchTable)
	research.researchTable = researchTable
	research.build()

	var items = load("res://Resources/items_table.tres")
	itemsTable.merge(items.itemsTable)
	items.itemsTable = itemsTable
	items.build()

	for i in itemsTable.keys():
		var item = itemsTable.get(i)
		if item.get("Fuel"):
			fuelIDs.push_back(i)

	var recipe = load("res://Resources/recipe_table.tres")
	recipeTable.merge(recipe.recipeTable)

	var effects = load("res://Resources/effects_table.tres")
	effectsTable.merge(effects.effectsTable)

	var spawner = load("res://Resources/spawner_table.tres")
	spawnerTable.append_array(spawner.spawnerTable)
	uiSpawnerTable.append_array(spawner.uiSpawnerTable)

	cache_resources()

	musicPlayer = load("res://Scenes/music_player.tscn").instantiate()
	musicPlayer.volume_db = -59
	add_child(musicPlayer)

	ambiencePlayer = load("res://Scenes/music_player.tscn").instantiate()
	ambiencePlayer.type = 1
	ambiencePlayer.volume_db = -59
	add_child(ambiencePlayer)

	var canvasKeyboard = load("res://keyboard_canvas.tscn").instantiate()
	add_child(canvasKeyboard)
	virtualKeyboard = canvasKeyboard.get_node("VirtualKeyboard")

	if voices.size() > 0:
		voice_id = voices[1]
















func convert_name(itemName):
	var newID = "starground:" + itemName.replace("starground:", "").to_lower().replace(" ", "_")
	if itemName != newID:
		return newID
	return itemName


func create_item_dict(itemID, amount):
	return {
		"ID": itemID, 
		"Amount": amount, 
		"Held": false, 
	}


func get_item_data(itemID):
	return itemsTable.get(itemID, itemsTable["starground:nai"])


var music = {
	"Mainmenu": [
		load("res://Sounds/Music/bedtime.ogg"), 
		load("res://Sounds/Music/dark_side_of_the_moon.ogg"), 
		load("res://Sounds/Music/grass_roots.ogg"), 
	], 
	"Automation": [
		load("res://Sounds/Music/nice_day.ogg"), 
		load("res://Sounds/Music/new_life.ogg"), 
		load("res://Sounds/Music/twinkling_void.ogg"), 
		load("res://Sounds/Music/outside.ogg"), 
		load("res://Sounds/Music/beautiful_moment.ogg"), 
		load("res://Sounds/Music/research.ogg"), 
		load("res://Sounds/Music/blueprint.ogg"), 
	], 
	"Dungeon_1": [
		load("res://Sounds/Music/mold.ogg"), 
		load("res://Sounds/Music/symbiotic_machine.ogg"), 
		load("res://Sounds/Music/lair.ogg"), 
		load("res://Sounds/Music/yuck_puddle.ogg"), 
	], 
	"Hub": [
		load("res://Sounds/Music/rewind.ogg"), 
		load("res://Sounds/Music/lounge.ogg"), 
		load("res://Sounds/Music/fountain_wishes.ogg"), 
	], 
}

var ambience = {
	"Mainmenu": [], 
	"Automation": [
		load("res://Sounds/Sound Effects/nature_ambience.wav"), 
	], 
	"Dungeon_1": [
		load("res://Sounds/Sound Effects/dungeon_1_ambience.wav"), 
	], 
	"Hub": []
}




var buildingsTabs = [
	["Production", load("res://Sprites/icon_production.png")], 
	["Logistics", load("res://Sprites/icon_production.png")], 
	["Power", load("res://Sprites/icon_production.png")], 
	["Miscellaneous", load("res://Sprites/icon_production.png")]
]
