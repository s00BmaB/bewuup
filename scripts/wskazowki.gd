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
	# Zmienna total_minutes to czas w minutach z PlayerData
	var total_minutes: int = PlayerData.current_time

	# Obliczanie godzin i minut
	var hours = int(total_minutes / 60) % 12   # Liczymy godziny w systemie 12-godzinnym
	var minutes = total_minutes % 60           # Pozostałe minuty

	# Obliczanie kątów wskazówek:
	# 1 minuta = 6° (360° / 60 minut)
	# 1 godzina = 30° (360° / 12 godzin)
	# Dodatkowo 0.5° na każdą minutę dla wskazówki godzinowej (aby wskazówka godzinowa przesuwała się powoli)
	
	var minute_angle = deg_to_rad(minutes * 6)  # -90, aby 0 minut było na górze (12:00)
	var hour_angle = deg_to_rad((hours * 30 + minutes * 0.5))  # +0.5° dla każdej minuty

	# Ustawianie rotacji wskazówek
	minute_hand.rotation = minute_angle
	hour_hand.rotation = hour_angle


func _on_minus_pressed() -> void:
	PlayerData.current_time += 10
	$Label.text = str(PlayerData.current_time)


func _on_plus_pressed() -> void:
	PlayerData.current_time -= 10
	$Label.text = str(PlayerData.current_time)
