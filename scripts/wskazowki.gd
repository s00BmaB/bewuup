extends Node2D

@onready var hour_hand := $HourHand
@onready var minute_hand := $MinuteHand

# Funkcja wywoływana z zewnątrz (przez gracza lub wroga)
func set_time(total_minutes: int):
	# Zabezpieczenie przed brakiem wskazówek (gdyby _ready jeszcze nie zaszło przy instancjowaniu)
	if not hour_hand or not minute_hand:
		return

	var hours = int(total_minutes / 60) % 12
	var minutes = total_minutes % 60

	var minute_angle = deg_to_rad(-(minutes * 6))  
	var hour_angle = deg_to_rad(-(hours * 30 + minutes * 0.5))

	minute_hand.rotation = minute_angle
	hour_hand.rotation = hour_angle
