extends Node2D

signal died

@export var enemy_name: String = "Enemy"
@export var max_time: int = 120
@export var current_time: int = 120
@export var damage: int = 5 

func _ready():
	# Inicjalizacja zegara na start
	if has_node("Wskazowki"):
		$Wskazowki.set_time(current_time)

	# Stary kod paska (do usunięcia/zakomentowania):
	# if $HealthBar:
	# 	$HealthBar.max_value = max_time
	# 	$HealthBar.value = current_time

func lose_time(amount: int):
	current_time -= amount
	current_time = max(current_time, 0)
	
	# Aktualizacja zegara po otrzymaniu obrażeń
	if has_node("Wskazowki"):
		$Wskazowki.set_time(current_time)
	
	# Stary kod paska (do usunięcia/zakomentowania):
	# if $HealthBar:
	# 	$HealthBar.value = current_time
	
	if current_time <= 0:
		die()

func die():
	print(enemy_name, " pokonany!")
	emit_signal("died") 
	queue_free()

func _on_mouse_enter():
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exit():
	modulate = Color(1, 1, 1)
