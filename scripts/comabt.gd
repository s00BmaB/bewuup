extends Node2D

@onready var enemy_container := $EnemyContainer
@onready var player_spawn := $PlayerSpawn

var level_data = {}  # tu załadujemy dane z JSON
var level_file: String = ""

func _ready():
	level_file = PlayerData.current_map_node
	print(level_file)
	load_level(level_file)
	spawn_player()
	spawn_enemies()

func load_level(path: String):
	if !FileAccess.file_exists(path):
		push_error("Plik nie istnieje: %s" % path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	level_data = JSON.parse_string(json_text)
	
func spawn_enemies():
	var screen_size = get_viewport_rect().size
	var enemy_count = min(level_data["enemies"].size(), 4)  # max 4

	# Odległość między przeciwnikami
	var spacing = 150  # px między przeciwnikami
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
