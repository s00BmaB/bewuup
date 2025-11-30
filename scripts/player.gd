extends Node2D

@export var max_time: int = 720
var current_time: int = 720
var block: int = 0

func _ready():
	# ZMIANA: Pobieramy current_time zamiast hp
	current_time = PlayerData.current_time
	max_time = PlayerData.max_time
	update_time_display()

func update_time_display():
	if $HealthBar:
		$HealthBar.max_value = max_time
		$HealthBar.value = current_time
		
		# Ustawienie koloru paska na cyjan (czas)
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color.CYAN
		$HealthBar.add_theme_stylebox_override("fill", sb)

func add_block(amount: int):
	block += amount
	print("Gracz zyskał ", amount, " bloku. Razem: ", block)

func add_time(amount: int):
	current_time = min(current_time + amount, max_time)
	# Aktualizujemy też PlayerData, żeby stan zapisał się po walce
	PlayerData.current_time = current_time 
	update_time_display()
	print("Gracz odzyskał ", amount, " czasu.")

func can_afford(cost: int) -> bool:
	return current_time >= cost

func spend_time(amount: int):
	if current_time >= amount:
		current_time -= amount
		PlayerData.current_time = current_time # Synchronizacja z PlayerData
		update_time_display()
		return true
	return false

func lose_time(amount: int):
	if block > 0:
		var absorbed = min(amount, block)
		block -= absorbed
		amount -= absorbed
		print("Blok zredukował utratę czasu o ", absorbed)
	
	if amount > 0:
		current_time -= amount
		PlayerData.current_time = current_time # Synchronizacja z PlayerData
		update_time_display()
		if current_time <= 0:
			die()

func die():
	print("Czas się skończył! Game Over.")
	queue_free()
