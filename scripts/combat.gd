extends Node2D

@onready var enemy_container := $EnemyContainer
@onready var player_spawn := $PlayerSpawn
@onready var card_pile_ui := $CardPileUI 

@export var time_damage: int = 10
@export var hand_size: int = 5

@export_file("*.tscn") var win_scene_path: String = "res://scenes/win_screen.tscn"
@export_file("*.tscn") var game_over_scene_path: String = "res://scenes/game_over.tscn"

var level_data = {}
var level_file: String = ""
var current_player: Node2D = null
var is_game_over: bool = false 

func _ready():
	setup_card_ui_layout()
	await get_tree().process_frame
	setup_deck()
	
	level_file = PlayerData.current_map_node
	if level_file == "":
		level_file = "res://levels/level1.json"
	
	load_level(level_file)
	spawn_player()
	spawn_enemies()
	
	if card_pile_ui:
		if !card_pile_ui.card_added_to_dropzone.is_connected(_on_card_dropped_on_zone):
			card_pile_ui.card_added_to_dropzone.connect(_on_card_dropped_on_zone)
	
	start_turn()

# --- WARUNKI KOŃCOWE ---

func _on_player_died():
	print("DEBUG: Otrzymano sygnał śmierci gracza.")
	if is_game_over: return
	is_game_over = true
	
	print("PRZEGRANA! Przełączam scenę...")
	
	# Używamy call_deferred dla 100% pewności, że zmiana nastąpi w bezpiecznym momencie
	call_deferred("_change_scene_to_game_over")

func _change_scene_to_game_over():
	if game_over_scene_path != "":
		get_tree().change_scene_to_file(game_over_scene_path)
	else:
		print("Błąd: Brak ścieżki Game Over, wracam do menu.")
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_enemy_died():
	# Czekamy klatkę (call_deferred), aby upewnić się, że queue_free() zdążyło oznaczyć wroga
	call_deferred("_check_all_enemies_dead")

func _check_all_enemies_dead():
	if is_game_over: return
	
	var living_enemies = 0
	for child in enemy_container.get_children():
		# Sprawdzamy czy wróg nie jest już "martwy" (zakolejkowany do usunięcia)
		if not child.is_queued_for_deletion():
			living_enemies += 1
	
	print("DEBUG: Sprawdzanie wrogów. Pozostało: ", living_enemies)
	
	if living_enemies == 0:
		game_won()

func game_won():
	print("DEBUG: Wszystkie wrogi pokonane.")
	if is_game_over: return
	is_game_over = true
	
	print("WYGRANA! Zapisywanie i zmiana sceny...")
	
	# Logika zapisu
	if level_file not in PlayerData.completed_levels:
		PlayerData.completed_levels.append(level_file)
	PlayerData.save()
	
	# Zmiana sceny w trybie deferred
	call_deferred("_change_scene_to_win")

func _change_scene_to_win():
	if win_scene_path != "":
		get_tree().change_scene_to_file(win_scene_path)
	else:
		print("Błąd: Brak ścieżki Win Screen, wracam na mapę.")
		get_tree().change_scene_to_file("res://scenes/map.tscn")

# --- SPAWNOWANIE ---

func spawn_player():
	var screen_size = get_viewport_rect().size
	var player_scene = load("res://scenes/player.tscn").instantiate()
	player_spawn.add_child(player_scene)
	player_scene.position = Vector2(200, screen_size.y * 0.65)
	player_scene.scale = Vector2(3,3)
	player_scene.current_time = PlayerData.current_time
	player_scene.max_time = PlayerData.max_time
	
	current_player = player_scene
	
	# Podłączamy sygnał śmierci
	if !current_player.is_connected("died", _on_player_died):
		current_player.connect("died", _on_player_died)
	
	create_player_dropzone(player_scene)

func spawn_enemies():
	if not level_data.has("enemies"): return
	var screen_size = get_viewport_rect().size
	var enemy_count = min(level_data["enemies"].size(), 4)
	var spacing = 250
	var total_width = (enemy_count - 1) * spacing
	var start_x = screen_size.x - 200 - total_width

	for i in range(enemy_count):
		var enemy_info = level_data["enemies"][i]
		var enemy_scene = load(enemy_info["scene"]).instantiate()
		enemy_scene.scale = Vector2(1.25,1.25)
		enemy_container.add_child(enemy_scene)
		var x = start_x + i * spacing
		var y = screen_size.y * 0.5
		enemy_scene.position = Vector2(x, y)
		
		# Podłączamy sygnał śmierci
		if !enemy_scene.is_connected("died", _on_enemy_died):
			enemy_scene.connect("died", _on_enemy_died)
		
		create_enemy_dropzone(enemy_scene)

# --- LOGIKA TURY ---

func _on_end_turn_button_pressed():
	print("--- KONIEC TURY (Przycisk) ---")
	if is_game_over: return # Nie robimy nic, jeśli gra się skończyła
	end_turn()

func end_turn():
	# 1. Odrzuć karty
	var cards_in_hand = card_pile_ui.get_cards_in_pile(CardPileUI.Piles.hand_pile)
	for card in cards_in_hand:
		card_pile_ui.set_card_pile(card, CardPileUI.Piles.discard_pile)
	
	# 2. Obrażenia od czasu (Limit czasu)
	apply_time_damage()
	
	# 3. Jeśli gra trwa, zacznij nową turę
	if not is_game_over:
		call_deferred("start_turn")

func start_turn():
	if is_game_over: return
	print("--- NOWA TURA ---")
	var current_hand_count = card_pile_ui.get_card_pile_size(CardPileUI.Piles.hand_pile)
	var cards_to_draw = hand_size - current_hand_count
	
	if cards_to_draw > 0:
		card_pile_ui.draw(cards_to_draw)

func apply_time_damage():
	print("Upływ czasu! (-", time_damage, ")")
	
	if is_instance_valid(current_player):
		current_player.lose_time(time_damage)
		
	# Iterujemy po wrogach. Jeśli któryś umrze, wyemituje sygnał died
	for enemy in enemy_container.get_children():
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			if enemy.has_method("lose_time"):
				enemy.lose_time(time_damage)

# --- RESZTA FUNKCJI POMOCNICZYCH (Bez zmian) ---

func create_enemy_dropzone(enemy_node: Node2D):
	var size_info = _calculate_hitbox_size(enemy_node)
	var dropzone = _instantiate_dropzone()
	dropzone.name = "EnemyDropzone"
	dropzone.set_meta("enemy", enemy_node)
	dropzone.custom_minimum_size = size_info["size"]
	dropzone.size = size_info["size"]
	dropzone.position = -size_info["size"] / 2 + size_info["offset"]
	dropzone.z_index = 10
	enemy_node.add_child(dropzone)

func create_player_dropzone(player_node: Node2D):
	var size_info = _calculate_hitbox_size(player_node)
	var dropzone = _instantiate_dropzone()
	dropzone.name = "PlayerDropzone"
	dropzone.set_meta("player", player_node)
	dropzone.custom_minimum_size = size_info["size"]
	dropzone.size = size_info["size"]
	dropzone.position = -size_info["size"] / 2
	dropzone.z_index = 10
	player_node.add_child(dropzone)

func _instantiate_dropzone() -> Control:
	var dropzone_script = load("res://scripts/centered_dropzone.gd")
	var dropzone = dropzone_script.new()
	dropzone.card_pile_ui = card_pile_ui
	return dropzone

func _calculate_hitbox_size(target_node: Node2D) -> Dictionary:
	var size = Vector2(100, 100)
	var offset = Vector2.ZERO
	var hitbox_area = target_node.get_node_or_null("Hitbox")
	if not hitbox_area:
		for child in target_node.get_children():
			if child is Area2D:
				hitbox_area = child
				break
	if hitbox_area:
		for child in hitbox_area.get_children():
			if child is CollisionShape2D and child.shape:
				var shape = child.shape
				var shape_size = Vector2.ZERO
				if shape is RectangleShape2D:
					shape_size = shape.size
				elif shape is CircleShape2D:
					shape_size = Vector2(shape.radius * 2, shape.radius * 2)
				var total_scale = child.scale * hitbox_area.scale
				size = shape_size * total_scale
				offset = child.position * hitbox_area.scale + hitbox_area.position
				break
	return {"size": size, "offset": offset}

func setup_card_ui_layout():
	if not card_pile_ui: return
	var screen_size = get_viewport_rect().size
	var margin_bottom = 150
	var margin_side = 150
	card_pile_ui.draw_pile_position = Vector2(margin_side, screen_size.y - margin_bottom)
	card_pile_ui.hand_pile_position = Vector2(screen_size.x / 2, screen_size.y - 50)
	card_pile_ui.discard_pile_position = Vector2(screen_size.x - margin_side, screen_size.y - margin_bottom)
	card_pile_ui.max_hand_spread = 600
	card_pile_ui.click_draw_pile_to_draw = false

func setup_deck():
	if not card_pile_ui: return
	clear_all_cards_in_ui()
	for card_name in PlayerData.deck:
		if card_exists_in_db(card_name):
			card_pile_ui.create_card_in_pile(card_name, CardPileUI.Piles.draw_pile)

func card_exists_in_db(card_name: String) -> bool:
	if not card_pile_ui.card_database: return false
	for card_data in card_pile_ui.card_database:
		if card_data.nice_name == card_name: return true
	return false

func clear_all_cards_in_ui():
	for pile in [CardPileUI.Piles.draw_pile, CardPileUI.Piles.hand_pile, CardPileUI.Piles.discard_pile]:
		var cards = card_pile_ui.get_cards_in_pile(pile)
		for card in cards:
			card_pile_ui.remove_card_from_game(card)

func load_level(path: String):
	if !FileAccess.file_exists(path): return
	var file = FileAccess.open(path, FileAccess.READ)
	level_data = JSON.parse_string(file.get_as_text())

func _on_card_dropped_on_zone(dropzone, card_ui):
	var card_data = card_ui.card_data
	var cost = card_data.cost
	var type = card_data.type
	var value = card_data.value
	
	if not current_player.can_afford(cost):
		print("Za mało czasu!")
		card_pile_ui.set_card_pile(card_ui, CardPileUI.Piles.hand_pile)
		return

	var played_successfully = false
	var target_enemy = null
	if dropzone.has_meta("enemy"): target_enemy = dropzone.get_meta("enemy")
	var target_player = null
	if dropzone.has_meta("player"): target_player = dropzone.get_meta("player")

	match type:
		"attack":
			if target_enemy and target_enemy.has_method("lose_time"):
				target_enemy.lose_time(value)
				played_successfully = true
				if SoundManager: SoundManager.play_hit()
		"defend":
			if target_player and target_player.has_method("add_block"):
				target_player.add_block(value)
				played_successfully = true
		"draw":
			card_pile_ui.draw(value)
			played_successfully = true
		"heal":
			if target_player and target_player.has_method("add_time"):
				target_player.add_time(value)
				played_successfully = true

	if played_successfully:
		current_player.spend_time(cost)
		card_pile_ui.set_card_pile(card_ui, CardPileUI.Piles.discard_pile)
	else:
		card_pile_ui.set_card_pile(card_ui, CardPileUI.Piles.hand_pile)

func _on_button_back():
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _process(delta: float) -> void:
	pass
