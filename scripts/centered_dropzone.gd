class_name CenteredDropzone extends CardDropzone

# Nie musimy deklarować zmiennych ani innych funkcji (add_card, remove_card itp.),
# ponieważ dziedziczymy je z klasy bazowej CardDropzone.
# Nadpisujemy TYLKO funkcję obliczającą pozycje kart.

func _update_target_positions():
	# Jeśli nie mamy referencji do UI, nie robimy nic
	if not is_instance_valid(card_pile_ui):
		return

	# 1. Pobieramy globalny środek dropzone'a (fix na centrowanie)
	var dropzone_center_global = get_global_rect().get_center()
	
	# Macierz do konwersji ze świata gry na lokalny układ UI
	var pile_transform_inverse = card_pile_ui.get_global_transform().affine_inverse()

	for i in _held_cards.size():
		var card_ui = _held_cards[i]
		if not is_instance_valid(card_ui): continue

		var target_global_pos = dropzone_center_global
		
		# Logika układania w stos (offsety)
		var offset = Vector2.ZERO
		if i > 0:
			var stack_index = i
			if stack_index > max_stack_display:
				stack_index = max_stack_display
				
			match layout:
				CardPileUI.PilesCardLayouts.up:
					offset.y -= stack_index * stack_display_gap
				CardPileUI.PilesCardLayouts.down:
					offset.y += stack_index * stack_display_gap
				CardPileUI.PilesCardLayouts.right:
					offset.x += stack_index * stack_display_gap
				CardPileUI.PilesCardLayouts.left:
					offset.x -= stack_index * stack_display_gap
		
		target_global_pos += offset
		
		# 2. Przeliczamy pozycję na lokalną dla CardPileUI
		var target_local_pos = pile_transform_inverse * target_global_pos
		
		# 3. Odejmujemy połowę rozmiaru karty (fix na anchor 0,0)
		target_local_pos -= card_ui.size / 2
		
		# Przypisanie pozycji
		card_ui.target_position = target_local_pos
		
		# Ustawienia wizualne (dziedziczone z CardDropzone)
		if card_ui_face_up:
			card_ui.set_direction(Vector2.UP)
		else:
			card_ui.set_direction(Vector2.DOWN)
			
		if card_ui.is_clicked:
			card_ui.z_index = 3000 + i 
		else:
			card_ui.z_index = i
		
		card_ui.move_to_front()

# Nie potrzebujemy funkcji _process, ponieważ klasa bazowa CardDropzone
# ma swój _process, który wywoła naszą nadpisaną funkcję _update_target_positions.
