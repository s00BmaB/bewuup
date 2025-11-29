extends Node2D

@export var enemy_name: String = "Enemy"
@export var max_hp: int = 20
@export var hp: int = 20
@export var damage: int = 5

func _ready():
	# ustaw pasek HP
	if $HealthBar:
		$HealthBar.max_value = max_hp
		$HealthBar.value = hp

func take_damage(amount: int):
	hp -= amount
	hp = max(hp, 0)
	
	if $HealthBar:
		$HealthBar.value = hp
	if hp <= 0:
		die()

func die():
	queue_free()
