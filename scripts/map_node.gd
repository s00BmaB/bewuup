extends Node2D

@onready var label := $Cont/Label
@onready var color := $Cont/ColorRect
@onready var button := $Cont/ColorRect/Button

var is_locked: bool = false
var is_completed: bool = false

func _ready():
	label.text = name

func set_status(status: String):
	# Statusy: "locked", "available", "completed"
	match status:
		"locked":
			is_locked = true
			is_completed = false
			button.disabled = true
			color.color = Color.GRAY # Szary dla zablokowanych
			modulate.a = 0.5
		"available":
			is_locked = false
			is_completed = false
			button.disabled = false
			color.color = Color(0, 0, 0.72, 1) # Niebieski (domyślny)
			modulate.a = 1.0
		"completed":
			is_locked = true # Ukończony też blokujemy (nie można powtarzać)
			is_completed = true
			button.disabled = true
			color.color = Color.GREEN # Zielony dla ukończonych
			modulate.a = 1.0

func _on_button_pressed():
	if is_locked: return
	
	color.color = Color.RED
	var json_file = "res://levels/%s.json" % name.to_lower()
	PlayerData.current_map_node = json_file
	get_tree().change_scene_to_file("res://scenes/combat.tscn")

func _on_button_released():
	if !is_locked:
		color.color = Color.BLUE
