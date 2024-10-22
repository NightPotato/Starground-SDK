extends Node

func add_building_entry(buildingID: String, entry: Dictionary)->void :
	Global.buildingsTable.merge({buildingID: entry}, true)

func create_research_entry(researchID, researchName, inputItems, unlocks, specialTags)->Dictionary:
	var entry = {
		researchID: {
			"Name": researchName, 
			"Input": inputItems, 
			"Unlocks": unlocks, 
		}
	}

	for i in specialTags:
		entry[researchID].merge(i)

	return entry

func add_research_entry(researchID: String, entry: Dictionary)->void :
	Global.researchTable.merge({researchID: entry}, true)

func create_item_entry(ID: String, Name: String, Sprite: Object, specialTags: Array[Dictionary] = [])->Dictionary:
	var entry: Dictionary = {
		ID: {
			"Name": Name, 
			"Sprite": Sprite, 
		}
	}

	for i in specialTags:
		entry[ID].merge(i)

	return entry

func add_item_entry(entry: Dictionary)->void :
	Global.itemsTable.merge(entry, true)

func create_effect_entry(effectID: String, effectName, effectScriptPath)->Dictionary:
	var entry: Dictionary = {
		effectID: {
			"Name": effectName, 
			"Resource": effectScriptPath, 
		}
	}

	return entry

func add_effect_entry(entry: Dictionary)->void :
	Global.effectsTable.merge(entry, true)

func add_spawner_entry(resourcePath: String)->void :
	Global.spawnerTable.push_back(resourcePath)

func add_ui_spawner_entry(resourcePath: String)->void :
	Global.uiSpawnerTable.push_back(resourcePath)

func replace_path(oldPath, newPath):
	load(newPath).take_over_path(oldPath)

func add_cache_entry(resourcePath: String)->void :
	Global.cacheTable.push_back(resourcePath)

func add_loot_entry(lootID: String, entry: Array)->void :
	Global.lootTable.merge({
		lootID: [entry]
	})

func choose_weighted_loot(lootID: String)->Array:
	var sum: float = 0.0
	for i: Array in Global.lootTable.get(lootID):
		sum += i[0]

	var rand: float = randf_range(0, sum)

	for i: Array in Global.lootTable.get(lootID):
		if rand < i[0]:
			return i
		rand -= i[0]
	return []
