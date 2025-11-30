class_name CardDropzone extends Control

@export var card_pile_ui : CardPileUI
@export var stack_display_gap := 8
@export var max_stack_display := 6
@export var card_ui_face_up := true
@export var can_drag_top_card := true
@export var held_card_direction := true
@export var layout : CardPileUI.PilesCardLayouts = CardPileUI.PilesCardLayouts.up

var _held_cards := []

func card_ui_dropped(card_ui : CardUI):
	if card_pile_ui:
		card_pile_ui.set_card_dropzone(card_ui, self)

func can_drop_card(card_ui : CardUI):
	return visible

func get_top_card():
	if _held_cards.size() > 0:
		return _held_cards[_held_cards.size() - 1]
	return null

func get_card_at(index):
	if _held_cards.size() > index:
		return _held_cards[index]
	return null

func get_total_held_cards():
	return _held_cards.size()

func is_holding(card_ui):
	return _held_cards.find(card_ui) != -1

func get_held_cards():
	return _held_cards.duplicate() 

func add_card(card_ui):
	_held_cards.push_back(card_ui)
	
func remove_card(card_ui):
	_held_cards = _held_cards.filter(func(c): return c != card_ui)

func _update_target_positions():
	# Jeśli nie mamy referencji do UI, nie możemy przeliczyć pozycji
	if not is_instance_valid(card_pile_ui):
		return

	# Pobieramy globalny środek dropzone'a (to miejsce, gdzie chcemy środek karty)
	var dropzone_center_global = get_global_rect().get_center()
	
	# Macierz transformacji pozwalająca przeliczyć pozycję ze świata na lokalną pozycję w CardPileUI
	var pile_transform_inverse = card_pile_ui.get_global_transform().affine_inverse()

	for i in _held_cards.size():
		var card_ui = _held_cards[i]
		if not is_instance_valid(card_ui): continue

		var target_global_pos = dropzone_center_global
		
		# Logika układania kart w stos (offsety)
		var offset = Vector2.ZERO
		if i > 0: # Pierwsza karta (0) jest idealnie na środku, kolejne są przesuwane
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
		
		# 1. Konwertujemy pozycję globalną na lokalną przestrzeń CardPileUI
		var target_local_pos = pile_transform_inverse * target_global_pos
		
		# 2. === POPRAWKA CENTROWANIA ===
		# Odejmujemy połowę rozmiaru karty, aby jej środek pokrywał się z punktem docelowym
		# (domyślnie pozycjonowany jest lewy górny róg)
		target_local_pos -= card_ui.size / 2
		
		# Aktualizacja karty
		card_ui.target_position = target_local_pos
		
		if card_ui_face_up:
			card_ui.set_direction(Vector2.UP)
		else:
			card_ui.set_direction(Vector2.DOWN)
			
		if card_ui.is_clicked:
			card_ui.z_index = 3000 + i 
		else:
			card_ui.z_index = i
		
		card_ui.move_to_front()

func _process(_delta):
	_update_target_positions()
