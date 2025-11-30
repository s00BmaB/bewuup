extends Node

# ZMIENNE
var current_time: int = 360
var max_time: int = 360
var gold: int = 0

@export var starting_strikes : int = 5
@export var starting_defends : int = 4

var deck: Array = []
var relics: Array = []
var inventory: Array = []

var current_map_node: String = ""
var completed_levels: Array = [] 

func _ready():
	# Inicjalizacja przy pierwszym uruchomieniu
	init_starting_deck()

# Nowa funkcja pomocnicza do tworzenia talii startowej
func init_starting_deck():
	deck.clear()
	for i in starting_strikes:
		deck.append("Strike")
	for i in starting_defends:
		deck.append("Defend")
	# Karty specjalne na start (według Twojego projektu)
	deck.append("Super Strike")
	deck.append("Look Into Timelines")

func reset():
	current_time = max_time

	relics.clear()
	inventory.clear()
	completed_levels.clear()
	init_starting_deck()
	
func load():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		if typeof(json) == TYPE_DICTIONARY:
			current_time = json.get("current_time", 100)
			max_time = json.get("max_time", 100)
			gold = json.gold
			deck = json.deck
			relics = json.relics
			inventory = json.inventory
			current_map_node = json.current_map_node
			completed_levels = json.get("completed_levels", [])
			
func save():
	var data = {
		"current_time": current_time,
		"max_time": max_time,
		"gold": gold,
		"deck": deck,
		"relics": relics,
		"inventory": inventory,
		"current_map_node": current_map_node,
		"completed_levels": completed_levels
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
