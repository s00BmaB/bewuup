extends Node2D

@onready var hour_hand := $HourHand
@onready var minute_hand := $MinuteHand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_clock()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_clock()


func update_clock():
	var total_minutes: int = PlayerData.time

	var hours = int(total_minutes / 60) % 12
	var minutes = total_minutes % 60

	# Kąty:
	# minuta = 6°
	# godzina = 30° + (minuty * 0.5°)
	# odjęcie 90°, bo Godot startuje od osi poziomej (prawej)
	var minute_angle = deg_to_rad(minutes * 6 - 90)
	var hour_angle = deg_to_rad((hours * 30 + minutes * 0.5) - 90)

	minute_hand.rotation = minute_angle
	hour_hand.rotation = hour_angle
