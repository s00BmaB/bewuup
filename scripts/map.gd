extends Node2D

@onready var connections := $Connections
@onready var nodes := [
	$Level1, $Level2, $Level3, $Level4, $Level5
]

func _ready():
	draw_connections()
	update_level_status()

func update_level_status():
	for node in nodes:
		node.set_status("locked")

	var first_level_path = "res://levels/level1.json"
	if first_level_path in PlayerData.completed_levels:
		nodes[0].set_status("completed")
	else:
		nodes[0].set_status("available")

	for i in range(nodes.size()):
		var current_node = nodes[i]
		var current_level_path = "res://levels/%s.json" % current_node.name.to_lower()
		
		if current_level_path in PlayerData.completed_levels:
			current_node.set_status("completed")

			if i + 1 < nodes.size():
				var next_node = nodes[i+1]

				var next_level_path = "res://levels/%s.json" % next_node.name.to_lower()
				if next_level_path not in PlayerData.completed_levels:
					next_node.set_status("available")

func draw_connections():
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

func _on_exit():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
