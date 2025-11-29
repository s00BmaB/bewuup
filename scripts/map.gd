extends Node2D

@onready var connections := $Connections
@onready var nodes := [
	$Level1,$Level2,$Level3,$Level4,$Level5
]

func _ready():
	draw_connections()

func draw_connections():
	# Przykładowe połączenia jak w Slay the Spire
	var edges = [
		[0, 1],
		[1, 2],
		[2, 3],
		[3, 4]
	]

	for edge in edges:
		var a = nodes[edge[0]].position
		var b = nodes[edge[1]].position
		connections.add_point(a)
		connections.add_point(b)
		# Dodaj przerwę między liniami
