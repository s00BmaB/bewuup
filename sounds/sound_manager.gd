extends Node2D

func play_click():
	$Click.play()

func play_hit():
	$Hit.play()

func play_enemy_attack():
	$EnemyAttack.play()

func play_music():
	$Music.play()

func stop_music():
	$Music.stop()

func play(name: String):
	if has_node(name):
		get_node(name).play()
	else:
		push_warning("Brak dźwięku: " + name)
