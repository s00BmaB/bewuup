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
	
	# zapisz level_file w singletonie lub globalnej zmiennej
	PlayerData.current_map_node = json_file
	
	
	get_tree().change_scene_to_file("res://scenes/comabt.tscn")
	
func _on_button_released():
	color.color = Color.BLUE
	
