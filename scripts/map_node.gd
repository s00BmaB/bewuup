extends Node2D


@onready var label := $Cont/Label
@onready var color := $Cont/ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = name   # <- automatycznie wstawia nazwę obiektu
	# Podłącz sygnał kliknięcia


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed():
	# zmiana koloru dla efektu kliknięcia
	color.color = Color.RED
	
	# nazwa node = "Level1" → tworzymy nazwę pliku JSON: "level1.json"
	var json_file = "res://levels/%s.json" % name.to_lower()
	print("Ładuję poziom z JSON:", json_file)

	# instancjonujemy scenę walki
	var combat_scene = load("res://scenes/comabt.tscn").instantiate()
	get_tree().root.add_child(combat_scene)
	
	get_tree().root.add_child(combat_scene)
	
	get_tree().current_scene.queue_free()
	
func _on_button_released():
	color.color = Color.BLUE
	
