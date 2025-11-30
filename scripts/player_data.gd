extends Node

# podstawowe dane gracza
var hp: int = 100
var max_hp: int = 100
var gold: int = 0

@export var starting_strikes : int = 5
@export var starting_defends : int = 5

# listy, słowniki, itp.
var deck: Array = []
var relics: Array = []
var inventory: Array = []

# dane o mapie, pozycji, itp.
var current_map_node: String = ""

func _ready():
	for i in starting_strikes:
		deck.append("Strike")
	for i in starting_defends:
		deck.append("Defend")
	deck.append("Super Strike")
	deck.append("Look Into Timelines")
	pass

# funkcje pomocnicze
func reset():
	hp = max_hp
	gold = 0
	deck.clear()
	relics.clear()
	inventory.clear()
	
func load():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		if typeof(json) == TYPE_DICTIONARY:
			hp = json.hp
			max_hp = json.max_hp
			gold = json.gold
			deck = json.deck
			relics = json.relics
			inventory = json.inventory
			current_map_node = json.current_map_node
			
func save():
	var data = {
		"hp": hp,
		"max_hp": max_hp,
		"gold": gold,
		"deck": deck,
		"relics": relics,
		"inventory": inventory,
		"current_map_node": current_map_node
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
