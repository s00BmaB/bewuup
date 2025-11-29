extends Node2D


@onready var label := $Cont/Label
@onready var color := $Cont/ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = name   # <- automatycznie wstawia nazwę obiektu
	# Podłącz sygnał kliknięcia


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed():
	color.color = Color.RED
	
func _on_button_released():
	color.color = Color.BLUE
	
