@tool
class_name CardUI extends Control


signal card_hovered(card: CardUI)
signal card_unhovered(card: CardUI)
signal card_clicked(card: CardUI)
signal card_dropped(card: CardUI)


@onready var frontface = $Frontface
@onready var backface = $Backface
@onready var icon_texture = $Frontface/Icon 
@onready var description_label = $Frontface/Description

@export var card_data : CardUIData


var frontface_texture : String
var backface_texture : String
var is_clicked := false
var mouse_is_hovering := false
var target_position := Vector2.ZERO
var return_speed := 0.2
var hover_distance := 10
var drag_when_clicked := true

func get_class(): return "CardUI"
func is_class(name): return name == "CardUI"


func set_direction(card_is_facing : Vector2):
	backface.visible = card_is_facing == Vector2.DOWN
	frontface.visible = card_is_facing == Vector2.UP

func set_disabled(val : bool):
	if val:
		mouse_is_hovering = false
		is_clicked = false
		rotation = 0
		var parent = get_parent()
		if parent is CardPileUI:
			parent.reset_card_ui_z_index()
			
func _ready():
	if Engine.is_editor_hint():
		set_disabled(true)
		update_configuration_warnings()
		return
	connect("mouse_entered", _on_mouse_enter)
	connect("mouse_exited", _on_mouse_exited)
	connect("gui_input", _on_gui_input)

	var card_scale = Vector2(4, 4) 

	var base_texture = load("res://assets/Averse2.png")
	frontface.texture = base_texture
	frontface.scale = card_scale 
	

	if backface_texture:
		backface.texture = load(backface_texture)
		backface.scale = card_scale 

	if frontface_texture:
		var icon_node = frontface.get_node_or_null("Icon")
		if icon_node:
			icon_node.texture = load(frontface_texture)

	custom_minimum_size = base_texture.get_size() * card_scale
	pivot_offset = (base_texture.get_size() * card_scale) / 2
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	var label_node = frontface.get_node_or_null("Description")
	label_node.scale = Vector2(1,1)
	if label_node and card_data:
		# 1. Jeśli wpisaliśmy ręczny opis w JSON (wymaga dodania pola 'description' w skrypcie danych), użyj go
		#if "description" in card_data and card_data.get("description") != "":
		#	label_node.text = card_data.description
			
		# 2. Jeśli nie ma opisu, wygeneruj go automatycznie na podstawie typu i wartości
		#elif "type" in card_data and "value" in card_data:
		if "type" in card_data and "value" in card_data:
			match card_data.type:
				"attack": 
					label_node.text = "Koszt: " + str(card_data.cost) + "\nAtak:" + str(card_data.value)
				"defend": 
					label_node.text = "Koszt: " + str(card_data.cost) + "\nBlok: " + str(card_data.value)
				"draw": 
					label_node.text = "Koszt: " + str(card_data.cost) + "\nDobierz: " + str(card_data.value)
				"heal": 
					label_node.text = "Koszt: " + str(card_data.cost) + "\nLecz: " + str(card_data.value)
				_:
					label_node.text = str(card_data.cost) + str(card_data.value)



func _card_can_be_interacted_with():
	var parent = get_parent()
	var valid = false
	if parent is CardPileUI:
		if parent.is_card_ui_in_hand(self):
			valid = parent.is_hand_enabled() and not parent.is_any_card_ui_clicked()
		var dropzone = parent.get_card_dropzone(self)
		if dropzone:
			valid = dropzone.get_top_card() == self and not parent.is_any_card_ui_clicked()
	return valid
			


func _on_mouse_enter():
	if _card_can_be_interacted_with():
		mouse_is_hovering = true
		target_position.y -= hover_distance
		var parent = get_parent()
		parent.reset_card_ui_z_index()
		emit_signal("card_hovered", self)


func _on_mouse_exited():
	if is_clicked:
		return
	if mouse_is_hovering:
		mouse_is_hovering = false
		target_position.y += hover_distance
		var parent = get_parent()
		if parent is CardPileUI:
			parent.reset_card_ui_z_index()
		emit_signal("card_unhovered", self)
	
func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var parent = get_parent()
			
			if _card_can_be_interacted_with():
				is_clicked = true
				rotation = 0
				parent.reset_card_ui_z_index()
				emit_signal("card_clicked", self)
			
			if parent is CardPileUI and parent.get_card_pile_size(CardPileUI.Piles.draw_pile) > 0 and parent.is_hand_enabled() and parent.get_cards_in_pile(CardPileUI.Piles.draw_pile).find(self) != -1 and not parent.is_any_card_ui_clicked() and parent.click_draw_pile_to_draw:
				parent.draw(1)
		else:
			#event released
			if is_clicked:
				is_clicked = false
				mouse_is_hovering = false
				rotation = 0
				var parent = get_parent()
				if parent is CardPileUI and parent.is_card_ui_in_hand(self):
					parent.call_deferred("reset_target_positions")
				var all_dropzones := []
				get_dropzones(get_tree().get_root(), "CardDropzone", all_dropzones)
				for dropzone in all_dropzones:
					if dropzone.get_global_rect().has_point(get_global_mouse_position()):
						if dropzone.can_drop_card(self):
							dropzone.card_ui_dropped(self)
							break
				emit_signal("card_dropped", self)
				emit_signal("card_unhovered", self)
			

func get_dropzones(node: Node, className : String, result : Array) -> void:
	if node is CardDropzone:
		result.push_back(node)
	for child in node.get_children():
		get_dropzones(child, className, result)

func _process(_delta):
	if is_clicked and drag_when_clicked:
		target_position = get_global_mouse_position() - custom_minimum_size * 0.5
	if is_clicked:
		position = target_position
	elif position != target_position:
		position = lerp(position, target_position, return_speed)
		
	if Engine.is_editor_hint() and last_child_count != get_child_count():
		update_configuration_warnings()
		last_child_count = get_child_count()

var last_child_count = 0

func _get_configuration_warnings():
	if get_child_count() != 2:
		return [ "This node must have 2 TextureRect as children, one named `Frontface` and one named `Backface`." ]
	for child in get_children():
		if not child is TextureRect or (child.name != "Frontface" and child.name != "Backface"):
			return [ "This node must have 2 TextureRect as children, one named `Frontface` and one named `Backface`." ]
	return []
