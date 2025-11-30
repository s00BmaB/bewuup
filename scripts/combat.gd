extends Node2D

@onready var enemy_container := $EnemyContainer
@onready var player_spawn := $PlayerSpawn
# Zakładam, że węzeł CardPileUI jest dzieckiem tej sceny (jak w pliku .tscn)
@onready var card_pile_ui := $CardPileUI 

var level_data = {}  # tu załadujemy dane z JSON
var level_file: String = ""

func _ready():
	# 1. Konfiguracja układu UI (Roguelike style)
	setup_card_ui_layout()
	
	# 2. Synchronizacja talii z PlayerData
	# Musimy poczekać klatkę, aby upewnić się, że CardPileUI się zainicjalizował
	await get_tree().process_frame
	setup_deck()
	
	# 3. Ładowanie poziomu
	level_file = PlayerData.current_map_node
	if level_file == "":
		level_file = "res://levels/level1.json" # Domyślny poziom testowy
	print("Loading level: ", level_file)
	load_level(level_file)
	
	spawn_player()
	spawn_enemies()
	
	# 4. Podłączenie sygnału upuszczenia karty
	if card_pile_ui:
		card_pile_ui.card_added_to_dropzone.connect(_on_card_dropped_on_zone)

# --- Konfiguracja UI i Talii ---

func setup_card_ui_layout():
	if not card_pile_ui: return
	
	var screen_size = get_viewport_rect().size
	var margin_bottom = 150
	var margin_side = 150
	
	# Układ: Stos dobierania (Lewy dół), Ręka (Środek dół), Stos odrzuconych (Prawy dół)
	card_pile_ui.draw_pile_position = Vector2(margin_side, screen_size.y - margin_bottom)
	card_pile_ui.hand_pile_position = Vector2(screen_size.x / 2, screen_size.y - 50)
	card_pile_ui.discard_pile_position = Vector2(screen_size.x - margin_side, screen_size.y - margin_bottom)
	
	# Opcjonalnie dostosuj szerokość wachlarza ręki
	card_pile_ui.max_hand_spread = 600

func setup_deck():
	if not card_pile_ui: return
	
	# Wyczyść karty z UI
	clear_all_cards_in_ui()
	
	# Dodaj karty z PlayerData
	for card_name in PlayerData.deck:
		# SPRAWDZENIE CZY KARTA ISTNIEJE W BAZIE
		if card_exists_in_db(card_name):
			card_pile_ui.create_card_in_pile(card_name, CardPileUI.Piles.draw_pile)
		else:
			push_error("BŁĄD: Karta o nazwie '" + card_name + "' nie istnieje w card_db.json! Pomijam.")
	
	# Dobierz rękę startową
	card_pile_ui.draw(5)

# Funkcja pomocnicza do sprawdzania bazy danych w CardPileUI
func card_exists_in_db(card_name: String) -> bool:
	if not card_pile_ui.card_database:
		return false
	for card_data in card_pile_ui.card_database:
		if card_data.nice_name == card_name:
			return true
	return false

func clear_all_cards_in_ui():
	# Helper do usunięcia wszystkich kart z UI przed synchronizacją
	for pile in [CardPileUI.Piles.draw_pile, CardPileUI.Piles.hand_pile, CardPileUI.Piles.discard_pile]:
		var cards = card_pile_ui.get_cards_in_pile(pile)
		for card in cards:
			card_pile_ui.remove_card_from_game(card)

# --- Logika Gry ---

func load_level(path: String):
	if !FileAccess.file_exists(path):
		push_error("Plik nie istnieje: %s" % path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	level_data = JSON.parse_string(json_text)
	
func spawn_enemies():
	if not level_data.has("enemies"): return
	
	var screen_size = get_viewport_rect().size
	var enemy_count = min(level_data["enemies"].size(), 4)  # max 4

	# Odległość między przeciwnikami
	var spacing = 250  # Zwiększyłem trochę odstęp dla czytelności dropzonów
	var total_width = (enemy_count - 1) * spacing
	var start_x = screen_size.x - 200 - total_width  # 200px od prawej krawędzi

	for i in range(enemy_count):
		var enemy_info = level_data["enemies"][i]
		var enemy_scene = load(enemy_info["scene"]).instantiate()
		enemy_container.add_child(enemy_scene)
		
		# Pozycja: x od prawej, y po środku ekranu
		var x = start_x + i * spacing
		var y = screen_size.y * 0.5
		enemy_scene.position = Vector2(x, y)
		
		# === TWORZENIE DROPZONE DLA PRZECIWNIKA ===
		create_enemy_dropzone(enemy_scene)

func create_enemy_dropzone(enemy_node: Node2D):
	# Tworzymy instancję klasy CardDropzone (z pliku skryptu)
	var dropzone_script = load("res://addons/simple_card_pile_ui/card_dropzone.gd")
	var dropzone = dropzone_script.new()
	
	dropzone.name = "EnemyDropzone"
	dropzone.card_pile_ui = card_pile_ui
	
	# Próba automatycznego dopasowania rozmiaru do Hitboxa przeciwnika
	var size_to_use = Vector2(150, 150) # Domyślny rozmiar
	var hitbox = enemy_node.get_node_or_null("Hitbox") # Szukamy węzła o nazwie Hitbox
	
	if hitbox:
		# Sprawdzamy czy to CollisionShape2D lub Area2D z CollisionShape2D
		var shape_owner = hitbox if hitbox is CollisionShape2D else null
		if not shape_owner and hitbox.get_child_count() > 0:
			for child in hitbox.get_children():
				if child is CollisionShape2D:
					shape_owner = child
					break
		
		if shape_owner and shape_owner.shape:
			var shape = shape_owner.shape
			if shape is RectangleShape2D:
				size_to_use = shape.size
			elif shape is CircleShape2D:
				size_to_use = Vector2(shape.radius * 2, shape.radius * 2)
	
	dropzone.custom_minimum_size = size_to_use
	dropzone.size = size_to_use
	
	# Wyśrodkowanie dropzone względem punktu zaczepienia przeciwnika
	dropzone.position = -size_to_use / 2
	
	# Powiązanie dropzone z konkretnym przeciwnikiem (kluczowe dla logiki walki)
	dropzone.set_meta("enemy", enemy_node)
	
	# Dodajemy dropzone jako dziecko przeciwnika - będzie się z nim poruszać
	enemy_node.add_child(dropzone)


func spawn_player():
	var screen_size = get_viewport_rect().size
	var player_scene = load("res://scenes/player.tscn").instantiate()
	player_spawn.add_child(player_scene)

	# Pozycja: po lewej, środek ekranu
	player_scene.position = Vector2(200, screen_size.y * 0.5)

	# HP z singletona
	player_scene.hp = PlayerData.hp
	
func _on_button_back():
	get_tree().change_scene_to_file("res://scenes/map.tscn")

# Obsługa zagrania karty na dropzone
func _on_card_dropped_on_zone(dropzone, card_ui):
	# Sprawdzamy czy upuszczono na przeciwnika
	if dropzone.has_meta("enemy"):
		var target_enemy = dropzone.get_meta("enemy")
		print("Zagrano kartę '", card_ui.card_data.nice_name, "' na przeciwnika: ", target_enemy.name)
		
		# TUTAJ DODAJ LOGIKĘ EFEKTU KARTY
		# np. var dmg = card_ui.card_data.damage
		# target_enemy.take_damage(dmg)
		
		# Po zagraniu przenieś kartę na stos odrzuconych
		card_pile_ui.set_card_pile(card_ui, CardPileUI.Piles.discard_pile)

# Called every frame.
func _process(delta: float) -> void:
	pass
