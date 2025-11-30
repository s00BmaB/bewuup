extends CardDropzone

# 1. Allow dropping ANY card to test the drag-and-drop mechanics
func can_drop_card(_card_ui: CardUI) -> bool:
	return true

# 2. When dropped, print info and move to discard
func card_ui_dropped(card_ui: CardUI):
	# DEBUG: Check if data loaded correctly
	if card_ui.card_data:
		print("TEST SUCCESS: Dropped card named: ", card_ui.card_data.nice_name)
	else:
		print("TEST WARNING: Card dropped, but no data found!")

	# LOGIC: Send the card to the discard pile immediately
	# This proves the manager can move cards between piles
	if card_pile_ui:
		card_pile_ui.set_card_pile(card_ui, card_pile_ui.Piles.discard_pile)
	else:
		print("ERROR: CardPileUI not connected in Inspector!")
