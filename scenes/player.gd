# Player.gd
extends Node2D

@export var max_hp: int = 100
var hp: int = 100

func _ready():
	# Ustaw HP na wartość z singletona PlayerData
	hp = PlayerData.hp
	max_hp = PlayerData.max_hp
	
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
	queue_free()  # gracz umiera w scenie walki
