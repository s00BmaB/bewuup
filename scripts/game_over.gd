extends CanvasLayer

@onready var label := $Label
@onready var button := $Button

func _ready():
	label.text = "Przegrałeś!"  # Tekst, który się wyświetli
	button.text = "Powrót do menu"
	
	# Wycentrowanie przycisku
	var screen_size = get_viewport().size  # Rozmiar ekranu
	var button_size = button.custom_minimum_size # Rozmiar przycisku
	
	print(button_size.x)
	# Ustawienie pozycji przycisku na środek ekranu
	button.position = Vector2(
		(screen_size.x - button_size.x) / 2, # Wyśrodkowanie poziome
		(screen_size.y - button_size.y) / 2 + 100   # Wyśrodkowanie pionowe
	)

# Funkcja wywoływana po kliknięciu przycisku
func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
