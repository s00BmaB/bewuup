extends Node2D

@export var max_hp: int = 100
var hp: int = 100
var block: int = 0  # Nowa zmienna na pancerz

func _ready():
	hp = PlayerData.hp
	max_hp = PlayerData.max_hp
	update_health_bar()

func update_health_bar():
	if $HealthBar:
		$HealthBar.max_value = max_hp
		$HealthBar.value = hp
		# Opcjonalnie: można dodać wizualizację bloku, np. zmieniając kolor lub dodając Label

func add_block(amount: int):
	block += amount
	print("Gracz zyskał ", amount, " bloku. Razem: ", block)

func heal(amount: int):
	hp = min(hp + amount, max_hp)
	update_health_bar()
	print("Gracz uleczony o ", amount)

func take_damage(amount: int):
	# Najpierw redukujemy blok
	if block > 0:
		var damage_to_block = min(amount, block)
		block -= damage_to_block
		amount -= damage_to_block
		print("Blok zredukował obrażenia o ", damage_to_block)
	
	# Reszta wchodzi w życie
	if amount > 0:
		hp -= amount
		hp = max(hp, 0)
		update_health_bar()
		if hp <= 0:
			die()

func die():
	print("Game Over")
	queue_free()
