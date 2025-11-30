extends CardDropzone

# We assume you have a global singleton named 'GameManager' or similar
# containing your player stats.

# 1. THE RULES: Can the player play this?
func can_drop_card(card_ui: CardUI) -> bool:
	# First, check if the dropzone is visible (base class logic)
	if not super.can_drop_card(card_ui):
		return false
	
	# access your custom data script
	var data = card_ui.card_data 
	
	# Example Rule: Do we have enough Mana?
	# Change 'mana_cost' to whatever variable name you used in your JSON/Data script
	if GameManager.current_mana >= data.cost:
		return true
		
	return false

# 2. THE EFFECT: What happens when played?
func card_ui_dropped(card_ui: CardUI):
	var data = card_ui.card_data
	
	# A. Deduct Resource
	GameManager.current_mana -= data.mana_cost
	
	# B. Do the effect
	print("Played card: ", data.nice_name)
	# You would likely call a combat function here, e.g.:
	# Enemy.take_damage(data.attack_power)
	
	# C. Decide where the card goes
	
	# OPTION 1: It's a spell (Instant use) -> Send to Discard Pile
	card_pile_ui.set_card_pile(card_ui, card_pile_ui.Piles.discard)
	
	# OPTION 2: It's a creature/building (Stays on board) -> Keep in Dropzone
	# If you want the card to stay on the table, call the parent function:
	# super.card_ui_dropped(card_ui)
